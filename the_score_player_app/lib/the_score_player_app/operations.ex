defmodule TheScorePlayerApp.Operations do
  @moduledoc false

  alias TheScorePlayerApp.Player
  alias TheScorePlayerApp.PlayerSync

  def players({:error, reason}), do: {:error, reason}

  def players(%{order_by: order_by, next_page: request_next_page, order: order, filter: filter}) do
    page_size = Application.fetch_env!(:the_score_player_app, :page_size)

    players = PlayerSync.players(order_by, filter, request_next_page, order, page_size)

    response_next_page = next_page(players, order_by, page_size)

    %{
      next_page: response_next_page,
      players: Enum.map(players, &Player.to_json_model/1)
    }
  end

  def players_csv({:error, reason}), do: {:error, reason}

  def players_csv(%{order_by: order_by, next_page: next_page, order: order, filter: filter}) do
    players = PlayerSync.players(order_by, filter, next_page, order)

    players
    |> Enum.reduce(Player.csv_header(), fn player, acc ->
      acc <> Player.csv_row(player)
    end)
  end

  defp next_page(players, _, limit) when length(players) < limit, do: nil

  defp next_page(players, :longest_rush, _limit) do
    %{longest_rush: longest_rush, td_on_longest_rush: td_on_longest_rush, player: player_name} =
      _player = List.last(players)

    "#{longest_rush}|#{td_on_longest_rush}|#{player_name}"
  end

  defp next_page(players, :player, _limit) do
    %{player: player_name} = _player = List.last(players)
    "#{player_name}"
  end

  defp next_page(players, field, _limit) do
    %{player: player_name} = player = List.last(players)
    "#{Map.get(player, field)}|#{player_name}"
  end
end
