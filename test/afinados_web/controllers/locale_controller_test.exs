defmodule AfinadosWeb.LocaleControllerTest do
  use AfinadosWeb.ConnCase, async: true

  defp choose(conn, locale), do: conn |> skip_csrf() |> post(~p"/locale/#{locale}")

  defp skip_csrf(conn), do: Plug.Conn.put_private(conn, :plug_skip_csrf_protection, true)

  test "choosing English persists the locale so the next page renders in English", %{conn: conn} do
    conn = choose(conn, "en")
    assert redirected_to(conn) == "/"

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ~s(<html lang="en">)
  end

  test "an unsupported locale is ignored and the app stays in Portuguese", %{conn: conn} do
    conn = choose(conn, "xx")

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ~s(<html lang="pt-BR">)
  end

  test "redirects back to the page the reader came from", %{conn: conn} do
    conn =
      conn
      |> put_req_header("referer", "https://app.afinados.io/carburetion/intake-sizing")
      |> choose("en")

    assert redirected_to(conn) == "/carburetion/intake-sizing"
  end

  test "never follows an off-site referer (no open redirect)", %{conn: conn} do
    conn =
      conn
      |> put_req_header("referer", "https://evil.example//evil.com/steal")
      |> choose("pt_BR")

    assert redirected_to(conn) == "/"
  end
end
