defmodule Afinados.Carburetion.IntakeSizingTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing

  alias Afinados.Carburetion.IntakeSizing.{
    Displacement,
    EngineConfig,
    VolumetricEfficiency
  }

  {:ok, config} =
    EngineConfig.new(%{
      k: 0.70,
      cylinders: 1,
      carbs: 1,
      barrels: 1,
      firing_interval: 720,
      manifold: :dedicated,
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

  describe "EngineConfig.new/1" do
    test "accepts a valid config" do
      assert {:ok, %EngineConfig{}} =
               EngineConfig.new(%{
                 k: 0.70,
                 cylinders: 4,
                 carbs: 1,
                 barrels: 2,
                 firing_interval: 180,
                 manifold: :dedicated,
                 boost: 0.0
               })
    end

    test "rejects non-positive K" do
      assert :error =
               EngineConfig.new(%{
                 k: 0,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 manifold: :dedicated,
                 boost: 0.0
               })
    end

    test "rejects an unknown manifold type" do
      assert :error =
               EngineConfig.new(%{
                 k: 0.70,
                 cylinders: 1,
                 carbs: 1,
                 barrels: 1,
                 firing_interval: 720,
                 manifold: :plenum,
                 boost: 0.0
               })
    end
  end

  describe "EngineConfig.pulse_divisor/1 — dedicated" do
    test "1 carb / 4 cyl / 180° firing → N = 3 (single carb with pulse overlap)" do
      {:ok, c} = with_carbs(1, manifold: :dedicated)
      assert_in_delta EngineConfig.pulse_divisor(c), 3.0, 1.0e-9
    end

    test "2-3-4 carbs / 4 cyl / 180° firing all saturate at N = 4 (per-carb bottleneck)" do
      {:ok, c2} = with_carbs(2, manifold: :dedicated)
      {:ok, c3} = with_carbs(3, manifold: :dedicated)
      {:ok, c4} = with_carbs(4, manifold: :dedicated)

      assert {EngineConfig.pulse_divisor(c2), EngineConfig.pulse_divisor(c3),
              EngineConfig.pulse_divisor(c4)} == {4.0, 4.0, 4.0}
    end

    test "5 carbs / 4 cyl bumps to N = 5 (venturi floor wins)" do
      {:ok, c} = with_carbs(5, manifold: :dedicated)
      assert_in_delta EngineConfig.pulse_divisor(c), 5.0, 1.0e-9
    end
  end

  describe "EngineConfig.pulse_divisor/1 — shared plenum" do
    test "1 carb shared matches dedicated (1 carb has to handle everything either way)" do
      {:ok, ded} = with_carbs(1, manifold: :dedicated)
      {:ok, sha} = with_carbs(1, manifold: :shared)
      assert_in_delta EngineConfig.pulse_divisor(ded), EngineConfig.pulse_divisor(sha), 1.0e-9
    end

    test "N scales linearly with carb count under shared plenum (4 cyl 180°)" do
      ns =
        for v <- 1..4 do
          {:ok, c} = with_carbs(v, manifold: :shared)
          EngineConfig.pulse_divisor(c)
        end

      assert_in_delta hd(ns), 3.0, 1.0e-6
      assert_in_delta Enum.at(ns, 1) / hd(ns), 2.0, 1.0e-6
      assert_in_delta Enum.at(ns, 2) / hd(ns), 3.0, 1.0e-6
      assert_in_delta Enum.at(ns, 3) / hd(ns), 4.0, 1.0e-6
    end
  end

  describe "commercial_diameters/0" do
    test "covers the even-mm catalog from 10 to 60" do
      assert IntakeSizing.commercial_diameters() == Enum.to_list(10..60//2)
    end
  end

  describe "target_velocity/1" do
    test "naturally aspirated stock motorcycle (K=0.70) targets ~65 m/s" do
      {:ok, c} = with_k(0.70)
      assert_in_delta IntakeSizing.target_velocity(c), 64.97, 0.1
    end

    test "naturally aspirated competition motorcycle (K=0.75) targets ~57 m/s" do
      {:ok, c} = with_k(0.75)
      assert_in_delta IntakeSizing.target_velocity(c), 56.59, 0.1
    end

    test "naturally aspirated stock car (K=0.60) targets ~88 m/s" do
      {:ok, c} = with_k(0.60)
      assert_in_delta IntakeSizing.target_velocity(c), 88.42, 0.1
    end

    test "1 bar of boost doubles the absolute pressure and the target velocity" do
      {:ok, na} = with_k(0.70, 0.0)
      {:ok, boosted} = with_k(0.70, 1.0)

      assert_in_delta IntakeSizing.target_velocity(boosted) / IntakeSizing.target_velocity(na),
                      2.0,
                      1.0e-6
    end

    test "higher K targets lower velocity (bigger venturi = lower velocity)" do
      {:ok, stock} = with_k(0.70)
      {:ok, race} = with_k(0.75)

      assert IntakeSizing.target_velocity(race) < IntakeSizing.target_velocity(stock)
    end
  end

  describe "gas_velocity/3" do
    test "at the K-derived ideal diameter, returns exactly the target velocity (loop closure)" do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      target = IntakeSizing.target_velocity(@config)

      ideal_d =
        ideal_diameter_for(%{displacement: displacement, ve: ve, config: @config, rpm: 8000})

      v_at_ideal =
        IntakeSizing.gas_velocity(ideal_d, 8000, %{
          displacement: displacement,
          ve: ve,
          config: @config
        })

      assert_in_delta v_at_ideal, target, 1.0e-6
    end

    test "doubling RPM doubles the gas velocity for a fixed diameter" do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      engine = %{displacement: displacement, ve: ve, config: @config}

      v_low = IntakeSizing.gas_velocity(22, 4000, engine)
      v_high = IntakeSizing.gas_velocity(22, 8000, engine)

      assert_in_delta v_high / v_low, 2.0, 1.0e-6
    end

    test "halving the diameter quadruples the gas velocity (D² in denominator)" do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      engine = %{displacement: displacement, ve: ve, config: @config}

      v_large = IntakeSizing.gas_velocity(28, 8000, engine)
      v_small = IntakeSizing.gas_velocity(14, 8000, engine)

      assert_in_delta v_small / v_large, 4.0, 1.0e-6
    end

    test "doubling the displacement doubles the gas velocity for a fixed diameter" do
      {:ok, small} = Displacement.new(125)
      {:ok, big} = Displacement.new(250)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      v_small =
        IntakeSizing.gas_velocity(22, 8000, %{displacement: small, ve: ve, config: @config})

      v_big = IntakeSizing.gas_velocity(22, 8000, %{displacement: big, ve: ve, config: @config})

      assert_in_delta v_big / v_small, 2.0, 1.0e-6
    end
  end

  describe "rpm_for_velocity/3" do
    test "is the inverse of gas_velocity" do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      engine = %{displacement: displacement, ve: ve, config: @config}
      diameter = 22

      v = IntakeSizing.gas_velocity(diameter, 9000, engine)
      rpm_back = IntakeSizing.rpm_for_velocity(diameter, v, engine)

      assert_in_delta rpm_back, 9000, 1.0e-6
    end

    test "at the target velocity, returns the RPM where that diameter is ideal" do
      {:ok, displacement} = Displacement.new(125)
      {:ok, ve} = VolumetricEfficiency.new(0.85)
      engine = %{displacement: displacement, ve: ve, config: @config}
      target = IntakeSizing.target_velocity(@config)
      diameter = 22

      rpm = IntakeSizing.rpm_for_velocity(diameter, target, engine)
      v_at_rpm = IntakeSizing.gas_velocity(diameter, rpm, engine)

      assert_in_delta v_at_rpm, target, 1.0e-6
    end
  end

  defp with_k(k, boost \\ 0.0) do
    EngineConfig.new(%{
      k: k,
      cylinders: 1,
      carbs: 1,
      barrels: 1,
      firing_interval: 720,
      manifold: :dedicated,
      boost: boost
    })
  end

  defp with_carbs(carbs, manifold: manifold) do
    EngineConfig.new(%{
      k: 0.70,
      cylinders: 4,
      carbs: carbs,
      barrels: 1,
      firing_interval: 180,
      manifold: manifold,
      boost: 0.0
    })
  end

  defp ideal_diameter_for(%{
         displacement: %Displacement{cc: cc},
         ve: %VolumetricEfficiency{value: ev},
         config: %EngineConfig{k: k} = config,
         rpm: rpm
       }) do
    n = EngineConfig.pulse_divisor(config)
    p_abs = EngineConfig.p_abs(config)
    k * :math.sqrt(cc * rpm * ev / (n * 1000 * p_abs))
  end
end
