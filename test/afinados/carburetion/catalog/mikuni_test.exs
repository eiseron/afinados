defmodule Afinados.Carburetion.Catalog.MikuniTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.Catalog.Mikuni

  test "needles include 4D3 with its jetsrus dimensions in integer fine units" do
    assert %{
             total_length_tenths_mm: 503,
             taper_points_tenths_mm: [253],
             station_diameters_um: [2511, 2511, 2421, 2253, 2100],
             num_clips: 5
           } = Enum.find(Mikuni.needles(), &(&1.part_number == "4D3"))
  end

  test "needle jet bore follows the letter (0.05 mm) and number (0.005 mm) system" do
    assert Mikuni.bore_um("159-P-4") == 2670
  end

  test "every needle has at least two stations and a positive length" do
    assert Enum.all?(
             Mikuni.needles(),
             &(length(&1.station_diameters_um) >= 2 and &1.total_length_tenths_mm > 0)
           )
  end

  test "every needle jet has a positive bore" do
    assert Enum.all?(Mikuni.needle_jets(), &(&1.bore_um > 0))
  end
end
