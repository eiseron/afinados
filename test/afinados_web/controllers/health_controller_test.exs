defmodule AfinadosWeb.HealthControllerTest do
  use AfinadosWeb.ConnCase, async: true

  test "GET /up returns 200 for the production uptime monitor", %{conn: conn} do
    conn = get(conn, ~p"/up")
    assert response(conn, 200) == "OK"
  end

  test "GET /healthz returns 200 for the preview compose health check", %{conn: conn} do
    conn = get(conn, ~p"/healthz")
    assert response(conn, 200) == "OK"
  end
end
