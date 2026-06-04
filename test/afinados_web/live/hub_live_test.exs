defmodule AfinadosWeb.HubLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "the hub lists the fuel-passage area tool linking to the simulator", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(href="/carburetion/setups")
  end

  test "the hub shows the venturi sizing tool as coming soon", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(class="tool-card tool-card-soon")
  end
end
