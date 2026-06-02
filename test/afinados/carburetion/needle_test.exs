defmodule Afinados.Carburetion.NeedleTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion
  alias Afinados.Carburetion.Needle

  setup do
    %{
      needle: %Needle{
        part_number: "4D3",
        total_length_mm: 50.3,
        taper_points_mm: [25.3],
        station_diameters_mm: [2.511, 2.511, 2.421, 2.253, 2.1],
        num_clips: 5
      }
    }
  end

  test "on the straight section, the diameter is the first station", %{needle: needle} do
    assert [Carburetion.diameter_at(needle, 0.0), Carburetion.diameter_at(needle, 25.3)] ==
             [2.511, 2.511]
  end

  test "at the needle tip, the diameter is the last station", %{needle: needle} do
    assert [Carburetion.diameter_at(needle, 50.3), Carburetion.diameter_at(needle, 99.0)] ==
             [2.1, 2.1]
  end

  test "at stations, returns the tabulated diameter", %{needle: needle} do
    assert Enum.map([37.8, 44.05], &Float.round(Carburetion.diameter_at(needle, &1), 4)) ==
             [2.421, 2.253]
  end

  test "between two stations, interpolates linearly", %{needle: needle} do
    assert_in_delta Carburetion.diameter_at(needle, 40.925), 2.337, 0.0001
  end

  test "the diameter is non-increasing along the needle (tapers toward the tip)", %{
    needle: needle
  } do
    diameters = Enum.map(0..100, &Carburetion.diameter_at(needle, &1 * 0.503))
    assert diameters == Enum.sort(diameters, :desc)
  end
end
