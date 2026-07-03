defmodule AfinadosWeb.AdminAccessPlug do
  @moduledoc """
  Gates the admin routes behind Cloudflare Access. When enabled, it requires a
  valid `Cf-Access-Jwt-Assertion` header (verified by `AfinadosWeb.CloudflareAccess`)
  whose `aud` matches the configured audiences; otherwise it responds 403 and
  halts. Disabled in dev/local, where no Access sits in front.
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    config = Application.get_env(:afinados, __MODULE__, [])

    case Keyword.get(config, :enabled, false) do
      true -> authorize(conn, config)
      false -> conn
    end
  end

  defp authorize(conn, config) do
    with [token] <- get_req_header(conn, "cf-access-jwt-assertion"),
         {:ok, claims} <- AfinadosWeb.CloudflareAccess.verify(token, config) do
      conn
      |> put_session(:admin_email, claims["email"])
      |> assign(:admin_email, claims["email"])
    else
      _ -> forbidden(conn)
    end
  end

  defp forbidden(conn) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:forbidden, "Forbidden")
    |> halt()
  end
end
