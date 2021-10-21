# theScore Player backend App

the_score_player_app is an Elixir backend service for providing player data read from `rushing.json`. It uses in-memory storage for fast responses.

### Model

`Player`:

```
{
    `Player`: <string>, # (Player's name)
    `Team`: <string>, # (Player's team abbreviation)
    `Pos`: <string>, # (Player's postion)
    `Att/G`: <number>, # (Rushing Attempts Per Game Average)
    `Att`: <number>, # (Rushing Attempts)
    `Yds`: <number>, # (Total Rushing Yards)
    `Avg`: <number>, # (Rushing Average Yards Per Attempt)
    `Yds/G`: <number>, # (Rushing Yards Per Game)
    `TD`: <number>, # (Total Rushing Touchdowns)
    `Lng` <string>, # (Longest Rush -- a `T` represents a touchdown occurred)
    `1st` <number>, # (Rushing First Downs)
    `1st%`: <number>, # (Rushing First Down Percentage)
    `20+`: <number>, # (Rushing 20+ Yards Each)
    `40+`: <number>, # (Rushing 40+ Yards Each)
    `FUM`: <number>, # (Rushing Fumbles)
}
```

### Routes

- `GET /players` - fetches player data

  - query params:
    - `filter` - search filter (player name)
    - `order_by` - field to order by (` player, yards, longest_rush, touchdowns`)
    - `order` - `asc` or `desc`
    - `next_page` - next page string
  - returns `JSON`:
    ```
    {
        "players": [], # list of players
        "next_page": <string> # next page token
    }
    ```

- `GET /players/csv` - downloads player data as csv
  - query params:
    - `filter` - search filter (player name)
    - `order_by` - field to order by (` player, yards, longest_rush, touchdowns`)
    - `order` - `asc` or `desc`
  - returns file download
