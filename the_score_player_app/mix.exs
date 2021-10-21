defmodule TheScorePlayerApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :the_score_player_app,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TheScorePlayerApp.Application, []}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.1"},
      {:jason, "~> 1.2"},
      {:ex_shards, "~> 0.2"},
      {:deferred_config, "~> 0.1.0"},
      {:assert_value, ">= 0.0.0"}
    ]
  end
end
