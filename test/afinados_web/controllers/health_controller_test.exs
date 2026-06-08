defmodule AfinadosWeb.HealthControllerTest do
  use AfinadosWeb.ConnCase, async: true

  test "GET /up returns 200 for the kamal-proxy health check", %{conn: conn} do
    conn = get(conn, ~p"/up")
    assert response(conn, 200) == "OK"
  end
end
