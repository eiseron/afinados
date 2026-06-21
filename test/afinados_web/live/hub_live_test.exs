defmodule AfinadosWeb.HubLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "the hub lists the fuel-passage area tool linking to the simulator", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(href="/carburetion/setups")
  end

  test "the hub links the intake sizing tool to its page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(href="/carburetion/intake-sizing")
  end
end
