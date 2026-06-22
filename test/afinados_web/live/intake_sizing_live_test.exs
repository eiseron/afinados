defmodule AfinadosWeb.IntakeSizingLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @default_params %{
    vehicle: "motorcycle",
    cc: "125",
    cylinders: "1",
    carbs: "1",
    barrels: "1",
    firing_interval: "720",
    k: "0.70",
    boost: "0",
    ve: "0.85"
  }

  describe "mount" do
    test "renders the efficiency zone with default parameters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, ".envelope")
      assert has_element?(view, ".ve-curve")
    end

    test "shows the Ve percentage for the default", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ "85%"
    end
  end

  describe "change event" do
    test "updating displacement regenerates the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "600"}})

      assert has_element?(view, ".envelope")
    end

    test "multiple carburetors computes without error", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "600", carbs: "2"}})

      assert has_element?(view, ".envelope")
    end

    test "changing application profile recomputes the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | k: "0.75"}})

      assert has_element?(view, ".envelope")
    end

    test "adding boost pressure recomputes the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | boost: "1.0"}})

      assert has_element?(view, ".envelope")
    end

    test "switching vehicle type resets the application profile", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | vehicle: "car"}})

      assert has_element?(view, ".envelope")
    end

    test "invalid displacement hides the chart", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "0"}})

      assert has_element?(view, ".chart-empty")
      refute has_element?(view, ".envelope")
    end
  end

  describe "commercial sizes" do
    test "renders commercial size lines on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, ".commercial-line")
      assert has_element?(view, ".commercial-label")
    end

    test "renders highlighted window segments within the envelope", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, ".commercial-window")
    end

    test "commercial lines update when displacement changes", %{conn: conn} do
      {:ok, view, html_before} = live(conn, "/carburetion/intake-sizing")

      html_after =
        view
        |> element("form")
        |> render_change(%{intake_sizing: %{@default_params | cc: "450"}})

      labels_before = Regex.scan(~r/class="commercial-label"[^>]*>\s*(\d+)/, html_before)
      labels_after = Regex.scan(~r/class="commercial-label"[^>]*>\s*(\d+)/, html_after)

      refute labels_before == labels_after
    end

    test "hides commercial lines when the chart is empty", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "0"}})

      refute has_element?(view, ".commercial-line")
    end
  end
end
