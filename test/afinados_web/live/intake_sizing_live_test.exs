defmodule AfinadosWeb.IntakeSizingLiveTest do
  use AfinadosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @default_params %{
    vehicle: "motorcycle",
    purpose: "urban",
    cc: "125",
    cylinders: "1",
    carbs: "1",
    barrels: "1",
    firing_interval: "720",
    manifold: "dedicated",
    induction: "carburetor",
    k: "0.70",
    boost: "0",
    ve: "0.95"
  }

  describe "mount" do
    test "renders the efficiency zone with default parameters", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, ".chart-panel")
    end

    test "no longer renders the Ve curve", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      refute has_element?(view, ".ve-curve")
    end

    test "no longer renders commercial crossing markers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      refute has_element?(view, ".commercial-crossing")
    end

    test "exposes the default Ve_max value through the form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      assert html =~ "value=\"0.95\""
    end
  end

  describe "change event" do
    test "updating displacement regenerates the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "600"}})

      assert has_element?(view, ".chart-panel")
    end

    test "multiple carburetors computes without error", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "600", carbs: "2"}})

      assert has_element?(view, ".chart-panel")
    end

    test "changing application profile recomputes the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | k: "0.75"}})

      assert has_element?(view, ".chart-panel")
    end

    test "adding boost pressure recomputes the zone", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | boost: "1.0"}})

      assert has_element?(view, ".chart-panel")
    end

    test "switching vehicle type resets the application profile", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | vehicle: "car"}})

      assert has_element?(view, ".chart-panel")
    end

    test "invalid displacement hides the chart", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cc: "0"}})

      assert has_element?(view, ".chart-empty")
      refute has_element?(view, ".chart-panel")
    end
  end

  describe "commercial sizes" do
    test "renders commercial size lines on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, ".commercial-line")
      assert has_element?(view, ".commercial-label")
    end

    test "commercial line uses a gradient stroke", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ ~r/class="commercial-line" stroke="url\(#vel-grad-/
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

  describe "basic and advanced sections" do
    test "renders the basic fieldset", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, "fieldset.basic")
    end

    test "renders the advanced fieldset", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, "fieldset.advanced")
    end

    test "advanced section is collapsed by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      refute has_element?(view, ".advanced-fields")
    end

    test "collapsed advanced section shows an ellipsis hint", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, "fieldset.advanced p.advanced-collapsed", "…")
    end

    test "expanding the advanced section hides the ellipsis hint", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view |> element("button[phx-click='toggle-advanced']") |> render_click()

      refute has_element?(view, ".advanced-collapsed")
    end

    test "advanced toggle has aria-expanded false by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, "button[phx-click='toggle-advanced'][aria-expanded='false']")
    end

    test "clicking the advanced toggle reveals the fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("button[phx-click='toggle-advanced']")
      |> render_click()

      assert has_element?(view, ".advanced-fields")
    end

    test "clicking the advanced toggle twice hides the fields again", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view |> element("button[phx-click='toggle-advanced']") |> render_click()
      view |> element("button[phx-click='toggle-advanced']") |> render_click()

      refute has_element?(view, ".advanced-fields")
    end

    test "boost field renders inside the advanced section when open", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      [_, advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert advanced =~ "intake_sizing[boost]"
    end

    test "barrels field renders inside the advanced section when open", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      [_, advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert advanced =~ "intake_sizing[barrels]"
    end

    test "VE slider renders inside the advanced section when open", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      [_, advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert advanced =~ "intake_sizing[ve]"
    end

    test "cylinders field lives in the basic section", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      [basic, _advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert basic =~ "intake_sizing[cylinders]"
    end

    test "carbs field lives in the basic section", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      [basic, _advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert basic =~ "intake_sizing[carbs]"
    end

    test "application profile (K) lives in the advanced section", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      [_, advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert advanced =~ "intake_sizing[k]"
    end

    test "purpose field lives in the basic section for multi-purpose vehicles",
         %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      [basic, _advanced] = String.split(html, ~r/<fieldset\b[^>]*class="advanced"/)
      assert basic =~ "intake_sizing[purpose]"
    end

    test "purpose field stays visible but disabled for stationary engines", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("form")
        |> render_change(%{intake_sizing: %{@default_params | vehicle: "stationary"}})

      assert html =~ "intake_sizing[purpose]"
      assert html =~ ~r/name="intake_sizing\[purpose\]"[^>]*disabled/
    end
  end

  describe "purpose select" do
    test "selecting a sport motorcycle still renders the chart", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | purpose: "sport"}})

      assert has_element?(view, ".chart-panel")
    end

    test "switching vehicle falls back to the new vehicle's default purpose",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("form")
        |> render_change(%{
          intake_sizing: %{@default_params | vehicle: "car", purpose: "sport"}
        })

      assert has_element?(view, ".chart-panel")
      assert html =~ "intake_sizing[purpose]"
    end
  end

  describe "real-world configurations through the form" do
    test "Honda CG 125 stock — basic-only inputs produce an envelope", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | vehicle: "motorcycle",
            cc: "125",
            cylinders: "1",
            carbs: "1",
            k: "0.70"
        }
      })

      assert has_element?(view, ".chart-panel")
    end

    test "Chevrolet Opala 4.1 — shared 2-bbl carb requires advanced fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | vehicle: "car",
            cc: "4093",
            cylinders: "6",
            carbs: "1",
            barrels: "2",
            firing_interval: "120",
            k: "0.60"
        }
      })

      assert has_element?(view, ".chart-panel")
    end

    test "Ford Maverick V8 with 2-bbl Motorcraft 2150 renders without error", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | vehicle: "car",
            cc: "4949",
            cylinders: "8",
            carbs: "1",
            barrels: "2",
            firing_interval: "90",
            k: "0.60"
        }
      })

      assert has_element?(view, ".chart-panel")
    end

    test "Harley Davidson Evo 1340 with V-twin 315° firing renders", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | vehicle: "motorcycle",
            cc: "1340",
            cylinders: "2",
            carbs: "1",
            barrels: "1",
            firing_interval: "315",
            k: "0.70"
        }
      })

      assert has_element?(view, ".chart-panel")
    end

    test "Fusca with twin Weber IDF 40 — competition config renders", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | vehicle: "car",
            cc: "1584",
            cylinders: "4",
            carbs: "2",
            barrels: "2",
            k: "0.70",
            ve: "0.90"
        }
      })

      assert has_element?(view, ".chart-panel")
    end
  end

  describe "gradient transitions on commercial lines" do
    test "defines a linearGradient per commercial line", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ ~r/<linearGradient id="vel-grad-\d+"/
    end

    test "gradient stops carry HSL stop colors", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ ~r/<stop offset="[\d.]+%" stop-color="hsl\(/
    end

    test "commercial line strokes from its gradient", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ ~r/class="commercial-line" stroke="url\(#vel-grad-\d+\)"/
    end

    test "Maverick V8 stock renders gradients without crashing", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("form")
        |> render_change(%{
          intake_sizing: %{
            @default_params
            | vehicle: "car",
              cc: "4949",
              cylinders: "8",
              carbs: "1",
              barrels: "2",
              firing_interval: "90",
              k: "0.60"
          }
        })

      assert html =~ ~r/<linearGradient id="vel-grad-\d+"/
    end
  end

  describe "color legend" do
    test "renders the legend ul", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      assert has_element?(view, "ul.legend")
    end

    test "renders six legend items", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      item_count = Regex.scan(~r/<li>\s*<svg class="swatch"/, html) |> length()
      assert item_count == 6
    end

    test "labels the fragile-ideal (cyan) row", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ "Aceitável"
    end

    test "labels the ideal color", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ "Ideal"
    end

    test "labels the working regime row", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ "Regime de trabalho do motor"
    end

    test "labels the out-of-regime row", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/carburetion/intake-sizing")

      assert html =~ "Fora do regime de trabalho"
    end
  end

  describe "firing interval availability" do
    test "is disabled when 1 cylinder per venturi", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      assert html =~ ~r/name="intake_sizing\[firing_interval\]"[^>]*disabled/
    end

    test "is enabled when cylinders share a carburetor", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{
        intake_sizing: %{
          @default_params
          | cylinders: "4",
            carbs: "1",
            barrels: "1"
        }
      })

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      refute html =~ ~r/name="intake_sizing\[firing_interval\]"[^>]*disabled/
    end
  end

  describe "intake manifold availability" do
    test "is disabled with 1 cylinder", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      assert html =~ ~r/name="intake_sizing\[manifold\]"[^>]*disabled/
    end

    test "is disabled with 1 carburetor", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cylinders: "4", carbs: "1"}})

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      assert html =~ ~r/name="intake_sizing\[manifold\]"[^>]*disabled/
    end

    test "is enabled when both cylinders and carburetors are >1", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

      view
      |> element("form")
      |> render_change(%{intake_sizing: %{@default_params | cylinders: "4", carbs: "2"}})

      html =
        view
        |> element("button[phx-click='toggle-advanced']")
        |> render_click()

      refute html =~ ~r/name="intake_sizing\[manifold\]"[^>]*disabled/
    end
  end

  test "the tool offers a contextual help link opening the interface docs in a new tab",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

    assert has_element?(
             view,
             ~s(a.doc-link-inline[target="_blank"][rel="noopener noreferrer"][href$="intake-sizing/interface"])
           )
  end

  test "expanding advanced reveals a help link to the advanced options docs", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/carburetion/intake-sizing")

    refute has_element?(view, ~s(a.doc-link-inline[href$="intake-sizing/interface#advanced"]))

    view |> element("button[phx-click='toggle-advanced']") |> render_click()

    assert has_element?(
             view,
             ~s(a.doc-link-inline[target="_blank"][href$="intake-sizing/interface#advanced"])
           )
  end
end
