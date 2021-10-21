defmodule TheScorePlayerApp.Player do
  @moduledoc false

  defstruct player: nil,
            team: nil,
            position: nil,
            attempts: 0,
            attempts_per_game: 0,
            yards: 0,
            avg: 0,
            yards_per_game: 0,
            touchdowns: 0,
            longest_rush: 0,
            td_on_longest_rush: false,
            first_downs: 0,
            first_downs_perc: 0,
            twenty_plus: 0,
            forty_plus: 0,
            fumbles: 0

  def parse_json_model(%{
        "Player" => player,
        "Team" => team,
        "Pos" => position,
        "Att" => attempts,
        "Att/G" => attemts_per_game,
        "Yds" => yards,
        "Avg" => avg,
        "Yds/G" => yards_per_game,
        "TD" => touchdowns,
        "Lng" => longest_rush,
        "1st" => first_downs,
        "1st%" => first_downs_perc,
        "20+" => twenty_plus,
        "40+" => forty_plus,
        "FUM" => fumbles
      }) do
    {longest_rush_num, td_on_longest_rush} = parse_longest_rush(longest_rush)

    %TheScorePlayerApp.Player{
      player: player,
      team: team,
      position: position,
      attempts: attempts,
      attempts_per_game: attemts_per_game,
      yards: parse_yards(yards),
      avg: avg,
      yards_per_game: yards_per_game,
      touchdowns: touchdowns,
      longest_rush: longest_rush_num,
      td_on_longest_rush: td_on_longest_rush,
      first_downs: first_downs,
      first_downs_perc: first_downs_perc,
      twenty_plus: twenty_plus,
      forty_plus: forty_plus,
      fumbles: fumbles
    }
  end

  def to_json_model(%TheScorePlayerApp.Player{
        player: player,
        team: team,
        position: position,
        attempts: attempts,
        attempts_per_game: attemts_per_game,
        yards: yards,
        avg: avg,
        yards_per_game: yards_per_game,
        touchdowns: touchdowns,
        longest_rush: longest_rush_num,
        td_on_longest_rush: td_on_longest_rush,
        first_downs: first_downs,
        first_downs_perc: first_downs_perc,
        twenty_plus: twenty_plus,
        forty_plus: forty_plus,
        fumbles: fumbles
      }) do
    longest_rush_suffix = if td_on_longest_rush, do: "T", else: ""

    %{
      "Player" => player,
      "Team" => team,
      "Pos" => position,
      "Att" => attempts,
      "Att/G" => attemts_per_game,
      "Yds" => yards,
      "Avg" => avg,
      "Yds/G" => yards_per_game,
      "TD" => touchdowns,
      "Lng" => "#{longest_rush_num}" <> longest_rush_suffix,
      "1st" => first_downs,
      "1st%" => first_downs_perc,
      "20+" => twenty_plus,
      "40+" => forty_plus,
      "FUM" => fumbles
    }
  end

  def csv_header(delimiter \\ ",", separator \\ "\n") do
    row =
      [
        "Player",
        "Team",
        "Pos",
        "Att",
        "Att/G",
        "Yds",
        "Avg",
        "Yds/G",
        "TD",
        "Lng",
        "1st",
        "1st%",
        "20+",
        "40+",
        "FUM"
      ]
      |> Enum.join(delimiter)

    row <> separator
  end

  def csv_row(
        %TheScorePlayerApp.Player{
          player: player,
          team: team,
          position: position,
          attempts: attempts,
          attempts_per_game: attemts_per_game,
          yards: yards,
          avg: avg,
          yards_per_game: yards_per_game,
          touchdowns: touchdowns,
          longest_rush: longest_rush_num,
          td_on_longest_rush: td_on_longest_rush,
          first_downs: first_downs,
          first_downs_perc: first_downs_perc,
          twenty_plus: twenty_plus,
          forty_plus: forty_plus,
          fumbles: fumbles
        },
        delimiter \\ ",",
        separator \\ "\n"
      ) do
    longest_rush_suffix = if td_on_longest_rush, do: "T", else: ""

    row =
      [
        player,
        team,
        position,
        attempts,
        attemts_per_game,
        yards,
        avg,
        yards_per_game,
        touchdowns,
        "#{longest_rush_num}" <> longest_rush_suffix,
        first_downs,
        first_downs_perc,
        twenty_plus,
        forty_plus,
        fumbles
      ]
      |> Enum.join(delimiter)

    row <> separator
  end

  defp parse_longest_rush(longest_rush) when is_integer(longest_rush),
    do: {longest_rush, false}

  defp parse_longest_rush(longest_rush) do
    longest_rush
    |> Integer.parse()
    |> case do
      {longest_rush_num, "T"} -> {longest_rush_num, true}
      {longest_rush_num, _} -> {longest_rush_num, false}
    end
  end

  defp parse_yards(yards) when is_integer(yards), do: yards

  defp parse_yards(yards) do
    yards
    |> String.split(",")
    |> Enum.join("")
    |> String.to_integer()
  end
end
