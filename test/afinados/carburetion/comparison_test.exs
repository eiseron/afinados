defmodule Afinados.Carburetion.ComparisonTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion

  alias Afinados.Carburetion.{
    Clip,
    Comparison,
    HighJet,
    LowJet,
    Needle,
    NeedleJet,
    Setup,
    Shim,
    Venturi
  }

  defp base_setup do
    %Setup{
      needle: %Needle{
        part_number: "4D3",
        total_length_mm: 50.3,
        taper_points_mm: [25.3],
        station_diameters_mm: [2.511, 2.511, 2.421, 2.253, 2.1],
        num_clips: 5
      },
      needle_jet: %NeedleJet{code: "159-P4", bore_mm: 2.7},
      high_jet: %HighJet{number: 150, free_area_mm2: :math.pi() / 4 * 1.5 * 1.5},
      low_jet: %LowJet{number: 25.0, free_area_mm2: 0.125},
      clip: %Clip{position: 3},
      shim: %Shim{hundredths: 0},
      venturi: %Venturi{mm: 34.0}
    }
  end

  defp diff(a, b) do
    Comparison.compute_difference(Carburetion.build_fuel_map(a), Carburetion.build_fuel_map(b))
  end

  test "returns a difference for every throttle position from 0% to 100%" do
    assert Enum.map(diff(base_setup(), base_setup()), & &1.position) == Enum.to_list(0..100)
  end

  test "comparing a setup with itself is zero everywhere" do
    assert Enum.all?(diff(base_setup(), base_setup()), &(&1.difference == 0.0))
  end

  test "a bigger pilot shifts the whole curve by a constant difference" do
    richer = %{base_setup() | low_jet: %LowJet{number: 50.0, free_area_mm2: 0.25}}
    diffs = Enum.map(diff(base_setup(), richer), & &1.difference)

    assert Enum.all?(diffs, &(abs(&1 - 0.125) < 1.0e-9))
  end

  test "the difference can change sign across the curve" do
    a = %{base_setup() | low_jet: %LowJet{number: 30.0, free_area_mm2: 0.15}}

    b = %{
      base_setup()
      | high_jet: %HighJet{number: 400, free_area_mm2: :math.pi() / 4 * 4.0 * 4.0}
    }

    diffs = Enum.map(diff(a, b), & &1.difference)

    assert Enum.any?(diffs, &(&1 < 0.0)) and Enum.any?(diffs, &(&1 > 0.0))
  end
end
