defmodule Afinados.Carburetion.IntakeSizingTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing

  alias Afinados.Carburetion.IntakeSizing.{
    CommercialSize,
    Displacement,
    EfficiencyZone,
    EngineConfig,
    VolumetricEfficiency
  }

  {:ok, config} =
    EngineConfig.new(%{
      k: 0.55,
      cylinders: 1,
      carbs: 1,
      barrels: 1,
      firing_interval: 720,
      boost: 0.0
    })

  @config config

  describe "Displacement.new/1" do
    test "accepts an integer displacement" do
      assert {:ok, %Displacement{cc: 125}} = Displacement.new(125)
    end

    test "rejects fractional displacement" do
      assert :error = Displacement.new(125.5)
    end

    test "rejects zero displacement" do
      assert :error = Displacement.new(0)
    end

    test "rejects negative displacement" do
      assert :error = Displacement.new(-50)
    end
  end

  describe "VolumetricEfficiency.new/1" do
    test "accepts a value at the lower bound" do
      assert {:ok, %VolumetricEfficiency{value: 0.5}} = VolumetricEfficiency.new(0.5)
    end

    test "accepts a value at the upper bound" do
      assert {:ok, %VolumetricEfficiency{value: 1.15}} = VolumetricEfficiency.new(1.15)
    end

    test "accepts a value within the range" do
      assert {:ok, %VolumetricEfficiency{value: 0.95}} = VolumetricEfficiency.new(0.95)
    end

    test "rejects a value below the range" do
      assert :error = VolumetricEfficiency.new(0.4)
    end

    test "rejects a value above the range" do
      assert :error = VolumetricEfficiency.new(1.16)
    end
  end

  describe "VolumetricEfficiency envelope" do
    test "envelope_max returns the slider value" do
      {:ok, ve} = VolumetricEfficiency.new(0.95)

      assert_in_delta VolumetricEfficiency.envelope_max(ve), 0.95, 1.0e-9
    end

    test "envelope_min subtracts 0.30 from the slider value" do
      {:ok, ve} = VolumetricEfficiency.new(0.95)

      assert_in_delta VolumetricEfficiency.envelope_min(ve), 0.65, 1.0e-9
    end

    test "envelope_min always preserves the 30-point width from the slider value" do
      {:ok, ve} = VolumetricEfficiency.new(0.5)

      assert_in_delta VolumetricEfficiency.envelope_min(ve), 0.2, 1.0e-9
    end
  end

  describe "EngineConfig.new/1" do
    test "accepts valid parameters" do
      assert {:ok, %EngineConfig{}} =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 boost: 0.0
               })
    end

    test "rejects zero cylinders" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 0,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 boost: 0.0
               })
    end

    test "rejects zero carburetors" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 1,
                 carbs: 0,
                 barrels: 1,
                 firing_interval: 720,
                 boost: 0.0
               })
    end

    test "rejects invalid barrels" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 3,
                 firing_interval: 720,
                 boost: 0.0
               })
    end

    test "rejects partial maps without raising" do
      assert :error = EngineConfig.new(%{k: 0.55})
    end

    test "rejects empty map without raising" do
      assert :error = EngineConfig.new(%{})
    end

    test "rejects nil input" do
      assert :error = EngineConfig.new(nil)
    end

    test "rejects non-map input" do
      assert :error = EngineConfig.new("string")
    end

    test "rejects firing interval out of range" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 800,
                 boost: 0.0
               })
    end

    test "rejects boost that zeroes p_abs" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.55,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 boost: -1.0
               })
    end

    test "rejects negative k" do
      assert :error =
               EngineConfig.new(%{
                 k: -0.1,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 boost: 0.0
               })
    end
  end

  describe "diameter_at/4" do
    test "implements D = K * sqrt(Vt * n * EV / (V * 1000))" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      expected = 0.55 * :math.sqrt(600 * 8000 * 0.85 / (1 * 1000))

      assert_in_delta IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: @config}),
                      expected,
                      1.0e-9
    end

    test "higher Ve produces larger diameter at the same rpm" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve_low} = VolumetricEfficiency.new(0.85)
      {:ok, ve_high} = VolumetricEfficiency.new(1.10)

      assert IntakeSizing.diameter_at(displacement, ve_high, %{rpm: 8000, config: @config}) >
               IntakeSizing.diameter_at(displacement, ve_low, %{rpm: 8000, config: @config})
    end

    test "higher rpm produces larger diameter at the same Ve" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.97)

      assert IntakeSizing.diameter_at(displacement, ve, %{rpm: 10_000, config: @config}) >
               IntakeSizing.diameter_at(displacement, ve, %{rpm: 6000, config: @config})
    end

    test "more carburetors produce smaller individual bore" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config_1c} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      {:ok, config_2c} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 2,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      assert IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_1c}) >
               IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_2c})
    end

    test "dual barrels double the effective venturi count" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, single} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 2,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      {:ok, dual} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 2,
          barrels: 2,
          firing_interval: 720,
          boost: 0.0
        })

      d_single = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: single})
      d_dual = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: dual})

      assert_in_delta d_dual, d_single / :math.sqrt(2), 1.0e-9
    end

    test "shared carb with non-overlapping pulses divides by cylinder count" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, single} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      {:ok, twin_360} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 1,
          barrels: 1,
          firing_interval: 360,
          boost: 0.0
        })

      d_single = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: single})
      d_twin = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: twin_360})

      assert_in_delta d_twin, d_single / :math.sqrt(2), 1.0e-9
    end

    test "tight firing interval increases peak via pulse overlap" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, twin_360} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 1,
          barrels: 1,
          firing_interval: 360,
          boost: 0.0
        })

      {:ok, twin_180} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      d_360 = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: twin_360})
      d_180 = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: twin_180})

      assert d_180 > d_360
    end

    test "firing interval has no effect when cylinders are not shared" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, wide} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 2,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      {:ok, tight} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 2,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      d_wide = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: wide})
      d_tight = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: tight})

      assert_in_delta d_wide, d_tight, 1.0e-9
    end

    test "boost halves the effective flow when P_abs doubles" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, na} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      {:ok, turbo} =
        EngineConfig.new(%{
          k: 0.55,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 1.0
        })

      d_na = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: na})
      d_turbo = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: turbo})

      assert_in_delta d_turbo, d_na / :math.sqrt(2), 1.0e-9
    end
  end

  describe "efficiency_zone/3" do
    setup do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.95)
      %{displacement: displacement, ve: ve}
    end

    test "returns an EfficiencyZone struct", %{displacement: d, ve: ve} do
      assert %EfficiencyZone{} = IntakeSizing.efficiency_zone(d, ve, @config)
    end

    test "the upper envelope bound uses the slider value as Ve_max", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)
      upper_at_8k = Enum.find(zone.envelope.upper, &(&1.rpm == 8000))
      expected = 0.55 * :math.sqrt(600 * 8000 * 0.95 / (1 * 1000))

      assert_in_delta upper_at_8k.diameter, expected, 1.0e-9
    end

    test "the lower envelope bound is Ve_max minus 0.30", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)
      lower_at_8k = Enum.find(zone.envelope.lower, &(&1.rpm == 8000))
      expected = 0.55 * :math.sqrt(600 * 8000 * 0.65 / (1 * 1000))

      assert_in_delta lower_at_8k.diameter, expected, 1.0e-9
    end

    test "no longer exposes a curve field", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)

      refute Map.has_key?(zone, :curve)
    end

    test "raising Ve_max widens both envelope bounds", %{displacement: d} do
      {:ok, ve_low} = VolumetricEfficiency.new(0.85)
      {:ok, ve_high} = VolumetricEfficiency.new(1.10)

      zone_low = IntakeSizing.efficiency_zone(d, ve_low, @config)
      zone_high = IntakeSizing.efficiency_zone(d, ve_high, @config)

      assert Enum.zip(zone_low.envelope.upper, zone_high.envelope.upper)
             |> Enum.all?(fn {low, high} -> high.diameter > low.diameter end)
    end

    test "envelope keeps 30-point width even at the slider minimum" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.5)
      zone = IntakeSizing.efficiency_zone(displacement, ve, @config)
      lower_at_8k = Enum.find(zone.envelope.lower, &(&1.rpm == 8000))
      expected = 0.55 * :math.sqrt(600 * 8000 * 0.2 / (1 * 1000))

      assert_in_delta lower_at_8k.diameter, expected, 1.0e-9
    end
  end

  describe "commercial_lines/3" do
    setup do
      {:ok, ve} = VolumetricEfficiency.new(0.95)
      %{ve: ve}
    end

    test "returns a non-empty list of CommercialSize structs", %{ve: ve} do
      {:ok, displacement} = Displacement.new(600)

      assert [%CommercialSize{} | _] = IntakeSizing.commercial_lines(displacement, ve, @config)
    end

    test "every RPM window has rpm_low < rpm_high", %{ve: ve} do
      {:ok, displacement} = Displacement.new(600)

      assert Enum.all?(
               IntakeSizing.commercial_lines(displacement, ve, @config),
               fn %CommercialSize{rpm_window: {lo, hi}} -> lo > 0 and hi > lo end
             )
    end

    test "a larger diameter needs higher RPM to enter the envelope", %{ve: ve} do
      {:ok, displacement} = Displacement.new(600)
      lines = IntakeSizing.commercial_lines(displacement, ve, @config)
      windows = Enum.map(lines, fn %CommercialSize{rpm_window: {lo, _}} -> lo end)

      assert windows == Enum.sort(windows)
    end

    test "the RPM window is the inverse of diameter_at" do
      {:ok, displacement} = Displacement.new(250)
      {:ok, ve} = VolumetricEfficiency.new(0.95)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      [%CommercialSize{diameter: d, rpm_window: {rpm_lo, rpm_hi}} | _] =
        IntakeSizing.commercial_lines(displacement, ve, config)

      {:ok, ve_envelope_max} = VolumetricEfficiency.new(VolumetricEfficiency.envelope_max(ve))
      {:ok, ve_envelope_min} = VolumetricEfficiency.new(VolumetricEfficiency.envelope_min(ve))

      assert_in_delta IntakeSizing.diameter_at(displacement, ve_envelope_max, %{
                        rpm: rpm_lo,
                        config: config
                      }),
                      d * 1.0,
                      1.0e-6

      assert_in_delta IntakeSizing.diameter_at(displacement, ve_envelope_min, %{
                        rpm: rpm_hi,
                        config: config
                      }),
                      d * 1.0,
                      1.0e-6
    end
  end

  describe "gas_velocity/3" do
    setup do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      %{engine: %{displacement: displacement, ve: ve, config: @config}}
    end

    test "is inversely proportional to area (D squared)", %{engine: engine} do
      v1 = IntakeSizing.gas_velocity(20, 9000, engine)
      v2 = IntakeSizing.gas_velocity(40, 9000, engine)

      assert_in_delta v1 / v2, 4.0, 1.0e-9
    end

    test "scales linearly with RPM", %{engine: engine} do
      slow = IntakeSizing.gas_velocity(22, 5000, engine)
      fast = IntakeSizing.gas_velocity(22, 10_000, engine)

      assert_in_delta fast / slow, 2.0, 1.0e-9
    end

    test "CG 125 at 22mm and 9000 rpm lands above the anemic floor", %{engine: engine} do
      velocity = IntakeSizing.gas_velocity(22, 9000, engine)

      assert velocity >= 50.0
    end

    test "CG 125 at 22mm and 9000 rpm stays below the choke ceiling", %{engine: engine} do
      velocity = IntakeSizing.gas_velocity(22, 9000, engine)

      assert velocity <= 250.0
    end
  end

  describe "real-world reference cases — stock motorcycles (K=0.70, VE=0.85)" do
    setup do
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      %{ve: ve, config: config}
    end

    test "Honda CG 125 — 125cc 4T single, 22mm Keihin", %{ve: ve, config: config} do
      {:ok, displacement} = Displacement.new(125)

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 9000, config: config})

      assert_in_delta diameter, 22.0, 2.0
    end

    test "Yamaha DT 180 — 180cc 2T single, 25mm Mikuni", %{ve: ve, config: config} do
      {:ok, displacement} = Displacement.new(180)

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config})

      assert_in_delta diameter, 25.0, 2.0
    end

    test "Yamaha DT 200 — 200cc 2T single, 26mm", %{ve: ve, config: config} do
      {:ok, displacement} = Displacement.new(200)

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config})

      assert_in_delta diameter, 26.0, 2.0
    end

    test "Yamaha TTR 230 — 223cc 4T trail, 26mm", %{ve: ve, config: config} do
      {:ok, displacement} = Displacement.new(223)

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 7500, config: config})

      assert_in_delta diameter, 26.0, 2.0
    end
  end

  describe "real-world reference cases — competition motorcycles (K=0.75)" do
    test "Honda CR 250R — 249cc 2T MX, 38mm Keihin PWK (VE=1.0)" do
      {:ok, displacement} = Displacement.new(249)
      {:ok, ve} = VolumetricEfficiency.new(1.0)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.75,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 10_500, config: config})

      assert_in_delta diameter, 38.0, 3.0
    end

    test "Honda CRF 450R — 449cc 4T MX, 40mm Keihin FCR-MX (VE=0.85)" do
      {:ok, displacement} = Displacement.new(449)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.75,
          cylinders: 1,
          carbs: 1,
          barrels: 1,
          firing_interval: 720,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8500, config: config})

      assert_in_delta diameter, 40.0, 3.0
    end
  end

  describe "real-world reference cases — stock cars (K=0.60, VE=0.80)" do
    setup do
      {:ok, ve} = VolumetricEfficiency.new(0.80)
      %{ve: ve}
    end

    test "VW Fusca 1600 — 1584cc flat-4, Solex H30/31 PIC ~24mm venturi", %{ve: ve} do
      {:ok, displacement} = Displacement.new(1584)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4000, config: config})

      assert_in_delta diameter, 24.0, 3.0
    end

    test "Fiat Uno Mille — 1049cc inline-4, Weber 32 TLF ~22mm venturi", %{ve: ve} do
      {:ok, displacement} = Displacement.new(1049)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4500, config: config})

      assert_in_delta diameter, 22.0, 3.0
    end

    test "Chevrolet Chevette 1.4 — 1398cc inline-4, Solex H30 PIC ~22mm venturi", %{ve: ve} do
      {:ok, displacement} = Displacement.new(1398)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4000, config: config})

      assert_in_delta diameter, 22.0, 3.0
    end

    test "Chevrolet Opala 2.5 — 2491cc inline-4, Solex H40 EIS ~28mm primary", %{ve: ve} do
      {:ok, displacement} = Displacement.new(2491)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 2,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4000, config: config})

      assert_in_delta diameter, 28.0, 3.0
    end

    test "Chevrolet Opala 4.1 — 4093cc inline-6, Solex 34 SEIE ~27mm primary", %{ve: ve} do
      {:ok, displacement} = Displacement.new(4093)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 6,
          carbs: 1,
          barrels: 2,
          firing_interval: 120,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 3500, config: config})

      assert_in_delta diameter, 27.0, 3.0
    end

    test "Ford Maverick V8 5.0 — 4949cc V8, Motorcraft 2150 ~27mm per barrel", %{ve: ve} do
      {:ok, displacement} = Displacement.new(4949)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 8,
          carbs: 1,
          barrels: 2,
          firing_interval: 90,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 3500, config: config})

      assert_in_delta diameter, 27.0, 3.0
    end
  end

  describe "real-world reference cases — competition cars (K=0.70)" do
    test "VW Fusca 1600 + twin Weber IDF 40 — 32mm chokes (VE=0.90, 6000 rpm)" do
      {:ok, displacement} = Displacement.new(1584)
      {:ok, ve} = VolumetricEfficiency.new(0.90)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 4,
          carbs: 2,
          barrels: 2,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 6000, config: config})

      assert_in_delta diameter, 32.0, 3.0
    end
  end

  describe "real-world reference cases — shared carb across cylinder phases" do
    test "Harley Davidson Evo 1340 — V-twin 45°, single Keihin CV40 (uneven 315° firing)" do
      {:ok, displacement} = Displacement.new(1340)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 1,
          barrels: 1,
          firing_interval: 315,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 5500, config: config})

      assert_in_delta diameter, 40.0, 3.0
    end

    test "Ford Corcel II 1.4 — 1372cc inline-4, Weber 32 DMTR ~22mm primary" do
      {:ok, displacement} = Displacement.new(1372)
      {:ok, ve} = VolumetricEfficiency.new(0.80)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 2,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4000, config: config})

      assert_in_delta diameter, 22.0, 3.0
    end

    test "Fiat 147 1050cc — inline-4, Weber 30 DIC single-barrel ~20mm venturi" do
      {:ok, displacement} = Displacement.new(1049)
      {:ok, ve} = VolumetricEfficiency.new(0.80)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 4000, config: config})

      assert_in_delta diameter, 20.0, 3.0
    end

    test "Envelope upper for Fusca 1600 matches stock 24mm carb at peak Ve_max" do
      {:ok, displacement} = Displacement.new(1584)
      {:ok, ve} = VolumetricEfficiency.new(0.95)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      zone = IntakeSizing.efficiency_zone(displacement, ve, config)
      upper_at_4k = Enum.find(zone.envelope.upper, &(&1.rpm == 4000))

      assert_in_delta upper_at_4k.diameter, 24.0, 3.0
    end

    test "Envelope lower for Fusca 1600 reflects 30-point Ve drop from Ve_max" do
      {:ok, displacement} = Displacement.new(1584)
      {:ok, ve} = VolumetricEfficiency.new(0.95)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.60,
          cylinders: 4,
          carbs: 1,
          barrels: 1,
          firing_interval: 180,
          boost: 0.0
        })

      zone = IntakeSizing.efficiency_zone(displacement, ve, config)
      lower_at_4k = Enum.find(zone.envelope.lower, &(&1.rpm == 4000))
      expected = 0.60 * :math.sqrt(1584 * 4000 * 0.65 / 3000)

      assert_in_delta lower_at_4k.diameter, expected, 1.0e-9
    end

    test "Classic BSA A50 500 — 360°-fire parallel twin, single Amal Concentric ~26mm" do
      {:ok, displacement} = Displacement.new(499)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config} =
        EngineConfig.new(%{
          k: 0.70,
          cylinders: 2,
          carbs: 1,
          barrels: 1,
          firing_interval: 360,
          boost: 0.0
        })

      diameter = IntakeSizing.diameter_at(displacement, ve, %{rpm: 6500, config: config})

      assert_in_delta diameter, 26.0, 3.0
    end
  end
end
