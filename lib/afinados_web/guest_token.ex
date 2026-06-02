defmodule AfinadosWeb.GuestToken do
  @moduledoc "Ensures the browser session carries a guest token, so work can be attached to a guest user."

  import Plug.Conn

  alias Afinados.Identity

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :guest_token) do
      nil -> put_session(conn, :guest_token, Identity.generate_token())
      _token -> conn
    end
  end
end
