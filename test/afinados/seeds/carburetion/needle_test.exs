defmodule Afinados.Seeds.Carburetion.NeedleTest do
  use ExUnit.Case, async: true

  alias Afinados.Seeds.Carburetion.Needle

  test "includes 4D3 with its jetsrus dimensions in integer fine units" do
    assert %{
             total_length_tenths_mm: 503,
             taper_points_tenths_mm: [253],
             station_diameters_um: [2511, 2511, 2421, 2253, 2100],
             num_clips: 5
           } = Enum.find(Needle.data(), &(&1.part_number == "4D3"))
  end

  test "every needle has at least two stations and a positive length" do
    assert Enum.all?(
             Needle.data(),
             &(length(&1.station_diameters_um) >= 2 and &1.total_length_tenths_mm > 0)
           )
  end
end
