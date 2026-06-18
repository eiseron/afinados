defmodule AfinadosWeb.GuestTokenTest do
  use AfinadosWeb.ConnCase, async: true

  defp guest_cookie(conn) do
    conn
    |> get_resp_header("set-cookie")
    |> Enum.find(&String.starts_with?(&1, "_afinados_key="))
  end

  test "the guest session cookie outlives the browser session (carries max-age)", %{conn: conn} do
    assert guest_cookie(get(conn, "/")) =~ ~r/max-age=\d+/i
  end

  test "the now-persistent guest session cookie is marked Secure", %{conn: conn} do
    assert guest_cookie(get(conn, "/")) =~ ~r/;\s*secure/i
  end
end
