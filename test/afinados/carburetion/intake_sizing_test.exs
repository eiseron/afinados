defmodule Afinados.Carburetion.IntakeSizingTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing

  alias Afinados.Carburetion.IntakeSizing.{
    Displacement,
    EfficiencyZone,
    EngineConfig,
    VolumetricEfficiency
  }

  {:ok, config} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 0.0})
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
      assert {:ok, %VolumetricEfficiency{value: 1.3}} = VolumetricEfficiency.new(1.3)
    end

    test "accepts a value within the range" do
      assert {:ok, %VolumetricEfficiency{value: 0.97}} = VolumetricEfficiency.new(0.97)
    end

    test "rejects a value below the range" do
      assert :error = VolumetricEfficiency.new(0.4)
    end

    test "rejects a value above the range" do
      assert :error = VolumetricEfficiency.new(1.31)
    end
  end

  describe "EngineConfig.new/1" do
    test "accepts valid parameters" do
      assert {:ok, %EngineConfig{}} =
               EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 0.0})
    end

    test "rejects zero carburetors" do
      assert :error = EngineConfig.new(%{k: 0.55, carbs: 0, cylinders: 2, boost: 0.0})
    end

    test "rejects zero cylinders" do
      assert :error = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 0, boost: 0.0})
    end

    test "rejects boost that zeroes p_abs" do
      assert :error = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: -1.0})
    end

    test "rejects negative k" do
      assert :error = EngineConfig.new(%{k: -0.1, carbs: 1, cylinders: 2, boost: 0.0})
    end
  end

  describe "diameter_at/4" do
    test "implements D = K * sqrt(Vt * n * EV / (C * 1000 * Nc))" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      expected = 0.55 * :math.sqrt(600 * 8000 * 0.85 / (1 * 1000 * 2))

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

    test "single-cylinder needs larger bore than 2-cylinder" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config_1cyl} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 1, boost: 0.0})
      {:ok, config_2cyl} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 0.0})

      assert IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_1cyl}) >
               IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_2cyl})
    end

    test "more carburetors produce smaller individual bore" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, config_1c} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 0.0})
      {:ok, config_2c} = EngineConfig.new(%{k: 0.55, carbs: 2, cylinders: 2, boost: 0.0})

      assert IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_1c}) >
               IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: config_2c})
    end

    test "boost halves the effective flow when P_abs doubles" do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.85)

      {:ok, na} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 0.0})
      {:ok, turbo} = EngineConfig.new(%{k: 0.55, carbs: 1, cylinders: 2, boost: 1.0})

      d_na = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: na})
      d_turbo = IntakeSizing.diameter_at(displacement, ve, %{rpm: 8000, config: turbo})

      assert_in_delta d_turbo, d_na / :math.sqrt(2), 1.0e-9
    end
  end

  describe "efficiency_zone/3" do
    setup do
      {:ok, displacement} = Displacement.new(600)
      {:ok, ve} = VolumetricEfficiency.new(0.97)
      %{displacement: displacement, ve: ve}
    end

    test "returns an EfficiencyZone struct", %{displacement: d, ve: ve} do
      assert %EfficiencyZone{} = IntakeSizing.efficiency_zone(d, ve, @config)
    end

    test "the lower envelope bound uses Ve_min", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)
      lower_at_8k = Enum.find(zone.envelope.lower, &(&1.rpm == 8000))
      expected = 0.55 * :math.sqrt(600 * 8000 * 0.5 / (1 * 1000 * 2))

      assert_in_delta lower_at_8k.diameter, expected, 1.0e-9
    end

    test "the upper envelope bound uses Ve_max", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)
      upper_at_8k = Enum.find(zone.envelope.upper, &(&1.rpm == 8000))
      expected = 0.55 * :math.sqrt(600 * 8000 * 1.3 / (1 * 1000 * 2))

      assert_in_delta upper_at_8k.diameter, expected, 1.0e-9
    end

    test "the curve lives within the envelope at every rpm", %{displacement: d, ve: ve} do
      zone = IntakeSizing.efficiency_zone(d, ve, @config)

      assert Enum.zip([zone.envelope.lower, zone.envelope.upper, zone.curve])
             |> Enum.all?(fn {lower, upper, curve} ->
               curve.diameter >= lower.diameter - 1.0e-9 and
                 curve.diameter <= upper.diameter + 1.0e-9
             end)
    end

    test "raising the Ve shifts the curve toward larger diameters", %{displacement: d} do
      {:ok, ve_low} = VolumetricEfficiency.new(0.85)
      {:ok, ve_high} = VolumetricEfficiency.new(1.10)

      zone_low = IntakeSizing.efficiency_zone(d, ve_low, @config)
      zone_high = IntakeSizing.efficiency_zone(d, ve_high, @config)

      assert Enum.zip(zone_low.curve, zone_high.curve)
             |> Enum.all?(fn {low, high} -> high.diameter > low.diameter end)
    end

    test "the envelope is the same regardless of the Ve chosen", %{displacement: d} do
      {:ok, ve_a} = VolumetricEfficiency.new(0.85)
      {:ok, ve_b} = VolumetricEfficiency.new(1.10)

      zone_a = IntakeSizing.efficiency_zone(d, ve_a, @config)
      zone_b = IntakeSizing.efficiency_zone(d, ve_b, @config)

      assert zone_a.envelope == zone_b.envelope
    end
  end
end
