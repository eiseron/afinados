defmodule AfinadosWeb.SetupLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Afinados.Carburetion.Catalog
  alias Afinados.Carburetion.Workbench
  alias Afinados.Garage
  alias Afinados.Repo

  setup do
    %Catalog.Needle{}
    |> Catalog.Needle.changeset(%{
      part_number: "4D3",
      manufacturer: "mikuni",
      total_length_tenths_mm: 503,
      taper_points_tenths_mm: [253],
      station_diameters_um: [2511, 2511, 2421, 2253, 2100],
      num_clips: 5
    })
    |> Repo.insert!()

    %Catalog.NeedleJet{}
    |> Catalog.NeedleJet.changeset(%{code: "159-P4", manufacturer: "mikuni", bore_um: 2700})
    |> Repo.insert!()

    :ok
  end

  defp change_params(venturi_mm) do
    %{
      "setup" => %{
        "part_number" => "4D3",
        "needle_jet_code" => "159-P4",
        "high_jet_number" => "150",
        "low_jet_number" => "25",
        "clip_position" => "3",
        "shim_hundredths" => "0",
        "venturi_mm" => venturi_mm
      }
    }
  end

  defp active_polyline(html) do
    [_, points] = Regex.run(~r/<polyline[^>]*points="([^"]+)"/, html)
    points
  end

  test "renders the seeded needle from the catalog", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ "4D3"
  end

  test "renders the curve as an SVG polyline with one point per throttle position", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    [_, points] = Regex.run(~r/<polyline[^>]*points="([^"]+)"/, html)

    assert length(String.split(points, " ", trim: true)) == 101
  end

  test "the curve shows intermediate Y-scale levels, not just min and max", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert length(Regex.scan(~r/text-anchor="end"/, html)) > 2
  end

  test "recomputes the curve when the venturi changes", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    refute active_polyline(render_change(view, "change", change_params("50"))) ==
             active_polyline(html)
  end

  test "falls back to a default venturi when the input is invalid", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    invalid = render_change(view, "change", change_params("abc"))

    assert active_polyline(invalid) ==
             active_polyline(render_change(view, "change", change_params("1")))
  end

  test "saving persists the current setup linked to the guest's garage", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    setup = Repo.one(Workbench.Setup)

    assert {setup.needle_part_number, setup.garage_id} == {"4D3", Repo.one(Garage).id}
  end

  test "a saved setup is listed for the guest", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "save") =~ "150/25 · 4D3 · clip 3"
  end

  test "loading a saved setup restores its curve", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    saved_curve = active_polyline(html)
    render_click(view, "save")
    render_change(view, "change", change_params("50"))
    [setup] = Repo.all(Workbench.Setup)

    assert active_polyline(render_click(view, "load", %{"id" => to_string(setup.id)})) ==
             saved_curve
  end

  test "ignores a load with a non-integer id without crashing", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    render_click(view, "save")

    assert active_polyline(render_click(view, "load", %{"id" => "not-an-int"})) ==
             active_polyline(html)
  end

  test "ignores a load when the guest has no garage yet", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert active_polyline(render_click(view, "load", %{"id" => "999"})) == active_polyline(html)
  end

  test "comparing a saved setup overlays a second curve", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    [setup] = Repo.all(Workbench.Setup)

    html = render_click(view, "toggle_compare", %{"id" => to_string(setup.id)})

    assert length(Regex.scan(~r/<polyline/, html)) == 2
  end

  test "unchecking a compared setup removes its curve", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    [setup] = Repo.all(Workbench.Setup)
    render_click(view, "toggle_compare", %{"id" => to_string(setup.id)})

    html = render_click(view, "toggle_compare", %{"id" => to_string(setup.id)})

    assert length(Regex.scan(~r/<polyline/, html)) == 1
  end

  test "comparing two different setups highlights the signed difference", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    render_change(view, "change", change_params("50"))
    [setup] = Repo.all(Workbench.Setup)

    html = render_click(view, "toggle_compare", %{"id" => to_string(setup.id)})

    assert html =~ "#16a34a"
  end

  test "toggling the X axis switches the unit from percent to millimetres", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "toggle_x_axis") =~ ~r{class="axis-unit">\s*mm\s*</text>}
  end

  test "labels the Y axis end with the mm² unit", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~r{class="axis-unit">\s*mm²\s*</text>}
  end

  test "labels the X axis end with the percent unit in throttle mode", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~r{class="axis-unit">\s*%\s*</text>}
  end

  test "in needle mode curves with different h0 start aligned at idle travel", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")

    render_change(view, "change", %{
      "setup" => Map.put(change_params("34")["setup"], "clip_position", "5")
    })

    [setup] = Repo.all(Workbench.Setup)
    render_click(view, "toggle_compare", %{"id" => to_string(setup.id)})
    html = render_click(view, "toggle_x_axis")

    starts =
      ~r/<polyline[^>]*points="([0-9.]+),/
      |> Regex.scan(html)
      |> Enum.map(fn [_, x] -> x end)

    assert match?([x, x], starts)
  end

  test "leads with the chart panel and places the setup controls after it", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    {chart_at, _} = :binary.match(html, ~s(class="curve"))
    {controls_at, _} = :binary.match(html, ~s(class="controls"))

    assert chart_at < controls_at
  end

  test "places the page heading below the chart, not above it", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    {chart_at, _} = :binary.match(html, ~s(class="curve"))
    {heading_at, _} = :binary.match(html, "<h1")

    assert chart_at < heading_at
  end

  test "offers the clip position as a select bounded by the needle's clip count", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    [select] = Regex.run(~r{<select[^>]*clip_position.*?</select>}s, html)

    assert length(Regex.scan(~r/<option/, select)) == 5
  end

  test "clamps an out-of-range clip position to the needle's clip count", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    over = change_params("34") |> put_in(["setup", "clip_position"], "100")
    at_max = change_params("34") |> put_in(["setup", "clip_position"], "5")

    assert active_polyline(render_change(view, "change", over)) ==
             active_polyline(render_change(view, "change", at_max))
  end

  test "the page links the bundled stylesheet", %{conn: conn} do
    assert html_response(get(conn, "/"), 200) =~ ~s(href="/assets/css/app.css")
  end

  test "the chart paints its grid lines through a themeable CSS class", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(class="grid-line")
  end

  test "the top bar renders a theme toggle", %{conn: conn} do
    assert html_response(get(conn, "/"), 200) =~ ~s(id="theme-toggle")
  end

  test "the top bar shows the running app version", %{conn: conn} do
    version = :afinados |> Application.spec(:vsn) |> to_string()

    assert html_response(get(conn, "/"), 200) =~ "v#{version}"
  end

  test "deleting a saved setup removes it", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    [setup] = Repo.all(Workbench.Setup)
    render_click(view, "delete", %{"id" => to_string(setup.id)})

    assert Repo.all(Workbench.Setup) == []
  end

  test "saving a setup shows a confirmation flash", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "save") =~ ~s(id="flash-info")
  end

  test "the saved panel shows how many setups are saved", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")

    assert render_click(view, "save") =~ ~r{class="count">\s*2}
  end

  test "the saved panel stays visible with an empty state when nothing is saved", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(class="empty")
  end

  test "collapsing the saved panel closes the details", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    refute render_click(view, "toggle_saved") =~ ~r{<details[^>]*\sopen}
  end

  test "selecting all overlays every saved setup", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    render_change(view, "change", change_params("50"))
    render_click(view, "save")

    html = render_click(view, "toggle_compare_all")

    assert length(Regex.scan(~r/<polyline/, html)) == 3
  end

  test "unselecting all clears the comparison", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    render_click(view, "toggle_compare_all")

    html = render_click(view, "toggle_compare_all")

    assert length(Regex.scan(~r/<polyline/, html)) == 1
  end
end
