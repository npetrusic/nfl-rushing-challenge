defmodule TheScorePlayerApp.PlayerSync do
  @moduledoc false

  use GenServer
  require Logger

  alias TheScorePlayerApp.Player

  @player_table :player_table

  def start_link(player_file_name) do
    GenServer.start_link(__MODULE__, {:ok, player_file_name}, name: __MODULE__)
  end

  def init({:ok, player_file_name}) do
    Logger.info("Init Sync started")

    ExShards.new(@player_table, [])

    player_file_name
    |> json_data()
    |> save_to_ets()

    Logger.info("Init Sync complete")
    {:ok, :sync_finished}
  end

  defp json_data(file_name) do
    file_name
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(&Player.parse_json_model/1)
  end

  defp save_to_ets([]), do: {:ok, :sync_finished}

  defp save_to_ets([
         %Player{
           player: player,
           yards: yards,
           longest_rush: longest_rush,
           td_on_longest_rush: td_on_longest_rush,
           touchdowns: touchdowns
         } = player_model
         | rest
       ]) do
    player_key = {player, yards, longest_rush, td_on_longest_rush, touchdowns}
    ExShards.insert(@player_table, {player_key, player_model})

    save_to_ets(rest)
  end

  def players(sort_by \\ :player, filter \\ nil, next_page \\ nil, order \\ :asc, limit \\ nil) do
    with {:ok, decoded_next_page} <- decode_next_page(next_page, sort_by) do
      players =
        sort_by
        |> fetch_players(decoded_next_page, order)
        |> apply_filter(filter)
        |> sort_results(sort_by, order)

      case limit do
        nil -> players
        number -> Enum.take(players, number)
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def apply_filter(players, nil), do: players

  def apply_filter(players, filter) do
    players
    |> Enum.filter(fn %{player: player_name} ->
      String.downcase(player_name) =~ String.downcase(filter)
    end)
  end

  def sort_results(players, :longest_rush, order) do
    players
    |> Enum.sort_by(
      fn %Player{
           player: player_name,
           longest_rush: longest_rush,
           td_on_longest_rush: td_on_longest_rush
         } ->
        {longest_rush, td_on_longest_rush, player_name}
      end,
      order
    )
  end

  def sort_results(players, field, order) do
    players
    |> Enum.sort_by(
      fn %Player{player: player_name} = player ->
        {Map.get(player, field), player_name}
      end,
      order
    )
  end

  def fetch_players(_, nil, _) do
    # Ex2ms.fun do
    # {{player, yards, longest_rush, td_on_longest_rush, touchdowns}, player_model} -> player_model end

    query = [{{{:"$1", :"$2", :"$3", :"$4", :"$5"}, :"$6"}, [], [:"$6"]}]

    ExShards.select(@player_table, query)
  end

  def fetch_players(order_by, {next_page, last_player_name}, order)
      when order_by in [:player, :yards, :touchdowns] do
    # Ex2ms.fun do
    # {{player, yards, longest_rush, td_on_longest_rush, touchdowns}, player_model}
    # when yards > "last_yards" or (yards == "last_yards" and player > "last_player")
    # -> player_model end

    sort_field = field_selector(order_by)

    query = [
      {{{:"$1", :"$2", :"$3", :"$4", :"$5"}, :"$6"},
       [
         {:orelse, {next_page_operator(order), sort_field, next_page},
          {:andalso, {:==, sort_field, next_page},
           {next_page_operator(order), :"$1", last_player_name}}}
       ], [:"$6"]}
    ]

    ExShards.select(@player_table, query)
  end

  def fetch_players(:longest_rush, {last_rush, last_td_flag, last_player_name}, order) do
    # Ex2ms.fun do
    # {{player, yards, longest_rush, td_on_longest_rush, touchdowns}, player_model}
    # when longest_rush > "last_longest_rush" or
    # (longest_rush == "last_longest_rush" and td_on_longest_rush > "last_td") or
    # (longest_rush == "last_longest_rush" and td_on_longest_rush == "last_td" and player > "last_player")
    # -> player_model end

    query = [
      {{{:"$1", :"$2", :"$3", :"$4", :"$5"}, :"$6"},
       [
         {:orelse,
          {:orelse, {next_page_operator(order), :"$3", last_rush},
           {:andalso, {:==, :"$3", last_rush}, {next_page_operator(order), :"$4", last_td_flag}}},
          {:andalso, {:andalso, {:==, :"$3", last_rush}, {:==, :"$4", last_td_flag}},
           {next_page_operator(order), :"$1", last_player_name}}}
       ], [:"$6"]}
    ]

    ExShards.select(@player_table, query)
  end

  defp next_page_operator(order) do
    if order == :asc, do: :>, else: :<
  end

  defp field_selector(:player), do: :"$1"
  defp field_selector(:yards), do: :"$2"
  defp field_selector(:touchdowns), do: :"$5"

  defp decode_next_page(nil, _), do: {:ok, nil}

  defp decode_next_page(next_page, :player), do: {:ok, {next_page, next_page}}

  defp decode_next_page(next_page, field) when field in [:yards, :touchdowns] do
    case String.split(next_page, "|") do
      [last_field_value, last_player_name] ->
        {:ok, {String.to_integer(last_field_value), last_player_name}}

      _ ->
        {:error, :invalid_next_page}
    end
  end

  defp decode_next_page(next_page, :longest_rush) do
    case String.split(next_page, "|") do
      [last_longest_rush, last_td_flag, last_player_name] ->
        {:ok,
         {String.to_integer(last_longest_rush), String.to_atom(last_td_flag), last_player_name}}

      _ ->
        {:error, :invalid_next_page}
    end
  end
end
