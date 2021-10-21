use Mix.Config

config :the_score_player_app,
  page_size: {:system, "THE_SCORE_APP_PAGE_SIZE", 20, {String, :to_integer}},
  allowed_frontend_endpoint:
    {:system, "THE_SCORE_APP_ALLOWED_FRONTEND_ENDPOINT", "http://localhost:3000"}

config :the_score_player_app, :data_config,
  player_file_name: {:system, "THE_SCORE_APP_PLAYER_FILE_NAME", "rushing.json"}
