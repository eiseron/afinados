defmodule AfinadosWeb.SetupLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Catalog, Clip, HighJet, LowJet, Setup, Shim, Venturi}
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

  defp max_area(venturi_mm) do
    {:ok, needle} = Catalog.fetch_needle("4D3")
    {:ok, needle_jet} = Catalog.fetch_needle_jet("159-P4")

    %Setup{
      needle: needle,
      needle_jet: needle_jet,
      high_jet: %HighJet{number: 150, free_area_mm2: :math.pi() / 4 * 1.5 * 1.5},
      low_jet: %LowJet{number: 25.0, free_area_mm2: 0.005 * 25.0},
      clip: %Clip{position: 3},
      shim: %Shim{hundredths: 0},
      venturi: %Venturi{mm: venturi_mm}
    }
    |> Carburetion.build_fuel_map()
    |> Map.fetch!(:points)
    |> Enum.map(& &1.free_area)
    |> Enum.max()
    |> :erlang.float_to_binary(decimals: 2)
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

  test "shows the maximum free area for the default setup", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ max_area(34.0)
  end

  test "recomputes the curve when the venturi changes", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_change(view, "change", change_params("50")) =~ max_area(50.0)
  end

  test "falls back to a default venturi when the input is invalid", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_change(view, "change", change_params("abc")) =~ max_area(1.0)
  end

  test "saving persists the current setup linked to the guest's garage", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    setup = Repo.one(Workbench.Setup)

    assert {setup.needle_part_number, setup.garage_id} == {"4D3", Repo.one(Garage).id}
  end

  test "a saved setup is listed for the guest", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "save") =~ "4D3 · clip 3 · 34 mm"
  end

  test "loading a saved setup restores its curve", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")
    render_change(view, "change", change_params("50"))
    [setup] = Repo.all(Workbench.Setup)

    assert render_click(view, "load", %{"id" => to_string(setup.id)}) =~ max_area(34.0)
  end

  test "ignores a load with a non-integer id without crashing", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_click(view, "save")

    assert render_click(view, "load", %{"id" => "not-an-int"}) =~ max_area(34.0)
  end

  test "ignores a load when the guest has no garage yet", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "load", %{"id" => "999"}) =~ max_area(34.0)
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

    assert html =~ "#dc2626" or html =~ "#16a34a"
  end
end
