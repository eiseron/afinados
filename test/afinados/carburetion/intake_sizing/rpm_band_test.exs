defmodule Afinados.Carburetion.IntakeSizing.RpmBandTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing.RpmBand

  describe "range/2 — motorcycle purposes" do
    test "urban (CG, daily commute) sits at 3k–7k" do
      assert RpmBand.range("motorcycle", "urban") == {3000, 7000}
    end

    test "cruiser (Harley, highway torque) — 2.5k–5.5k" do
      assert RpmBand.range("motorcycle", "cruiser") == {2500, 5500}
    end

    test "sport (R1 ridden hard on the road) — 6k–12k" do
      assert RpmBand.range("motorcycle", "sport") == {6000, 12_000}
    end

    test "track (closed circuit, near-redline sustained) — 9k–14k" do
      assert RpmBand.range("motorcycle", "track") == {9000, 14_000}
    end

    test "rally (Dakar / adventure) — 4k–10k" do
      assert RpmBand.range("motorcycle", "rally") == {4000, 10_000}
    end

    test "work (cargo / delivery) — 3k–6k" do
      assert RpmBand.range("motorcycle", "work") == {3000, 6000}
    end

    test "off-road sits at 4k–9k" do
      assert RpmBand.range("motorcycle", "off_road") == {4000, 9000}
    end

    test "hard enduro opens the low end (technical control) — 3k–9k" do
      assert RpmBand.range("motorcycle", "hard_enduro") == {3000, 9000}
    end

    test "motocross holds sustained high RPM — 7k–13k" do
      assert RpmBand.range("motorcycle", "motocross") == {7000, 13_000}
    end

    test "unknown purpose for a known vehicle falls back to its default" do
      assert RpmBand.range("motorcycle", "street_race") ==
               RpmBand.range("motorcycle", "urban")
    end
  end

  describe "range/2 — car purposes" do
    test "urban spans stop-and-go to fast urban roads (marginais, eixões) — 1.5k–4k" do
      assert RpmBand.range("car", "urban") == {1500, 4000}
    end

    test "highway sustains 80–120 km/h freeway cruise — 2.5k–4.5k" do
      assert RpmBand.range("car", "highway") == {2500, 4500}
    end

    test "sport opens the upper mid — 3.5k–6.5k" do
      assert RpmBand.range("car", "sport") == {3500, 6500}
    end

    test "track pushes higher — 4k–7k" do
      assert RpmBand.range("car", "track") == {4000, 7000}
    end

    test "drag widens for launch through peak — 4.5k–7k" do
      assert RpmBand.range("car", "drag") == {4500, 7000}
    end

    test "off-road (4x4, low gearing) stays low for torque — 1.5k–3.5k" do
      assert RpmBand.range("car", "off_road") == {1500, 3500}
    end

    test "rally covers mixed surfaces — 3k–6.5k" do
      assert RpmBand.range("car", "rally") == {3000, 6500}
    end

    test "work / utility under load keeps RPM down — 1.5k–3k" do
      assert RpmBand.range("car", "work") == {1500, 3000}
    end
  end

  describe "range/2 — other vehicles" do
    test "kart race holds 9k–14.5k" do
      assert RpmBand.range("kart", "race") == {9000, 14_500}
    end

    test "kart cross (off-road) — 7k–12k" do
      assert RpmBand.range("kart", "off_road") == {7000, 12_000}
    end

    test "stationary ignores purpose (synchronous only)" do
      assert RpmBand.range("stationary", "anything") == {2900, 3700}
    end

    test "outboard fishing stays low — 3k–4.5k" do
      assert RpmBand.range("outboard", "fishing") == {3000, 4500}
    end
  end

  describe "range/1 — defaults to a sensible purpose per vehicle" do
    test "motorcycle default = urban" do
      assert RpmBand.range("motorcycle") == RpmBand.range("motorcycle", "urban")
    end

    test "car default = urban" do
      assert RpmBand.range("car") == RpmBand.range("car", "urban")
    end

    test "unknown vehicle falls back to a generic band" do
      assert RpmBand.range("unknown") == {2000, 8000}
    end
  end

  describe "default_purpose/1" do
    test "motorcycle defaults to urban" do
      assert RpmBand.default_purpose("motorcycle") == "urban"
    end

    test "car defaults to urban" do
      assert RpmBand.default_purpose("car") == "urban"
    end

    test "kart defaults to race" do
      assert RpmBand.default_purpose("kart") == "race"
    end

    test "stationary defaults to synchronous" do
      assert RpmBand.default_purpose("stationary") == "synchronous"
    end
  end

  describe "purposes/1" do
    test "motorcycle covers all car-symmetric purposes plus moto-only ones" do
      assert RpmBand.purposes("motorcycle") ==
               ~w(urban cruiser sport track off_road hard_enduro motocross rally drag work)
    end

    test "car lists application-focused purposes (no shared moto naming)" do
      assert RpmBand.purposes("car") ==
               ~w(urban highway sport track drag off_road rally work)
    end

    test "kart adds off-road (kart cross) to race and leisure" do
      assert RpmBand.purposes("kart") == ~w(race off_road leisure)
    end

    test "stationary has a single synchronous option" do
      assert RpmBand.purposes("stationary") == ["synchronous"]
    end
  end

  describe "chart_max/1" do
    test "defaults to 14k RPM for most vehicles" do
      assert RpmBand.chart_max("motorcycle") == 14_000
    end

    test "extends to 17k RPM for karts (band reaches 14.5k)" do
      assert RpmBand.chart_max("kart") == 17_000
    end
  end
end
