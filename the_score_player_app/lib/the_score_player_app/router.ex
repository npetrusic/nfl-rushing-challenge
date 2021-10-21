defmodule TheScorePlayerApp.Router do
  @moduledoc false

  use Plug.Router
  import Plug.Conn

  alias TheScorePlayerApp.Application
  alias TheScorePlayerApp.Operations

  @legal_order_by ["player", "yards", "longest_rush", "touchdowns"]

  plug(:match)
  plug(:dispatch)

  get "/players" do
    conn = fetch_query_params(conn)

    conn.params
    |> validate_query_params()
    |> Operations.players()
    |> case do
      {:error, reason} ->
        handle_error(conn, reason)

      players ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("Access-Control-Allow-Origin", Application.frontend_endpoint())
        |> send_resp(200, Jason.encode!(players))
    end
  end

  get "/players/csv" do
    conn = fetch_query_params(conn)

    conn.params
    |> validate_query_params()
    |> Operations.players_csv()
    |> case do
      {:error, reason} ->
        handle_error(conn, reason)

      players_csv ->
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("Content-disposition", "attachment; filename=\"players.csv\"")
        |> put_resp_header("Access-Control-Allow-Origin", Application.frontend_endpoint())
        |> send_resp(200, players_csv)
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("Access-Control-Allow-Origin", Application.frontend_endpoint())
    |> send_resp(404, "Oops!")
  end

  def handle_error(conn, error) when error in [:invalid_order_by, :invalid_order] do
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("Access-Control-Allow-Origin", Application.frontend_endpoint())
    |> send_resp(400, Jason.encode!(%{error: error}))
  end

  def validate_query_params(query_params) do
    with {:ok, validated_order_by} <- validate(query_params["order_by"], :order_by),
         {:ok, validated_order} <- validate(query_params["order"], :order) do
      next_page = if query_params["next_page"] == "", do: nil, else: query_params["next_page"]

      %{
        order_by: validated_order_by || :player,
        order: validated_order || :asc,
        next_page: next_page,
        filter: query_params["filter"]
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate(nil, _), do: {:ok, nil}

  defp validate(order_by, :order_by) do
    case String.downcase(order_by) in @legal_order_by do
      true -> {:ok, String.to_atom(order_by)}
      false -> {:error, :invalid_order_by}
    end
  end

  defp validate(order, :order) do
    case String.downcase(order) in ["asc", "desc"] do
      true -> {:ok, String.to_atom(order)}
      false -> {:error, :invalid_order}
    end
  end
end
