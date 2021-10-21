defmodule TheScorePlayerApp.PlayerTest do
  @moduledoc false

  use ExUnit.Case
  import AssertValue

  alias TheScorePlayerApp.Player

  test "parse json model" do
    player_json_models = [
      %{
        "Player" => "player",
        "Team" => "team",
        "Pos" => "position",
        "Att" => 10,
        "Att/G" => 0.5,
        "Yds" => 20,
        "Avg" => 2,
        "Yds/G" => 2,
        "TD" => 5,
        "Lng" => 10,
        "1st" => 5,
        "1st%" => 0.5,
        "20+" => 5,
        "40+" => 5,
        "FUM" => 5
      },
      %{
        "Player" => "player",
        "Team" => "team",
        "Pos" => "position",
        "Att" => 10,
        "Att/G" => 0.5,
        "Yds" => "20",
        "Avg" => 2,
        "Yds/G" => 2,
        "TD" => 5,
        "Lng" => "10T",
        "1st" => 5,
        "1st%" => 0.5,
        "20+" => 5,
        "40+" => 5,
        "FUM" => 5
      }
    ]

    results = Enum.map(player_json_models, &Player.parse_json_model/1)

    assert_value(
      results == [
        %TheScorePlayerApp.Player{
          attempts: 10,
          attempts_per_game: 0.5,
          avg: 2,
          first_downs: 5,
          first_downs_perc: 0.5,
          forty_plus: 5,
          fumbles: 5,
          longest_rush: 10,
          player: "player",
          position: "position",
          td_on_longest_rush: false,
          team: "team",
          touchdowns: 5,
          twenty_plus: 5,
          yards: 20,
          yards_per_game: 2
        },
        %TheScorePlayerApp.Player{
          attempts: 10,
          attempts_per_game: 0.5,
          avg: 2,
          first_downs: 5,
          first_downs_perc: 0.5,
          forty_plus: 5,
          fumbles: 5,
          longest_rush: 10,
          player: "player",
          position: "position",
          td_on_longest_rush: true,
          team: "team",
          touchdowns: 5,
          twenty_plus: 5,
          yards: 20,
          yards_per_game: 2
        }
      ]
    )
  end

  test "to json model" do
    player_model = %TheScorePlayerApp.Player{
      attempts: 10,
      attempts_per_game: 0.5,
      avg: 2,
      first_downs: 5,
      first_downs_perc: 0.5,
      forty_plus: 5,
      fumbles: 5,
      longest_rush: 10,
      player: "player",
      position: "position",
      td_on_longest_rush: false,
      team: "team",
      touchdowns: 5,
      twenty_plus: 5,
      yards: 20,
      yards_per_game: 2
    }

    result = Player.to_json_model(player_model)

    assert_value(
      result == %{
        "1st" => 5,
        "1st%" => 0.5,
        "20+" => 5,
        "40+" => 5,
        "Att" => 10,
        "Att/G" => 0.5,
        "Avg" => 2,
        "FUM" => 5,
        "Lng" => "10",
        "Player" => "player",
        "Pos" => "position",
        "TD" => 5,
        "Team" => "team",
        "Yds" => 20,
        "Yds/G" => 2
      }
    )
  end

  test "csv header" do
    assert_value(
      Player.csv_header() ==
        "Player,Team,Pos,Att,Att/G,Yds,Avg,Yds/G,TD,Lng,1st,1st%,20+,40+,FUM\n"
    )
  end

  test "csv row" do
    player_model = %TheScorePlayerApp.Player{
      attempts: 10,
      attempts_per_game: 0.5,
      avg: 2,
      first_downs: 5,
      first_downs_perc: 0.5,
      forty_plus: 5,
      fumbles: 5,
      longest_rush: 10,
      player: "player",
      position: "position",
      td_on_longest_rush: false,
      team: "team",
      touchdowns: 5,
      twenty_plus: 5,
      yards: 20,
      yards_per_game: 2
    }

    result = Player.csv_row(player_model)

    assert_value(result == "player,team,position,10,0.5,20,2,2,5,10,5,0.5,5,5,5\n")
  end
end
