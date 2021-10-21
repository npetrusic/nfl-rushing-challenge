defmodule TheScorePlayerApp.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    DeferredConfig.populate(:the_score_player_app)

    children = [
      {Plug.Cowboy, scheme: :http, plug: TheScorePlayerApp.Router, options: [port: 4000]},
      {TheScorePlayerApp.PlayerSync, data_config()[:player_file_name]}
    ]

    opts = [strategy: :one_for_one, name: TheScorePlayerApp.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def data_config, do: Application.fetch_env!(:the_score_player_app, :data_config)

  def frontend_endpoint,
    do: Application.fetch_env!(:the_score_player_app, :allowed_frontend_endpoint)
end
