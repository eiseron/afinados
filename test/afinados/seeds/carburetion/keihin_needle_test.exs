defmodule Afinados.Seeds.Carburetion.KeihinNeedleTest do
  use Afinados.DataCase, async: true

  alias Afinados.Carburetion.Catalog
  alias Afinados.Seeds.Carburetion.KeihinNeedle

  describe "data/0" do
    test "loads the full N427-48, N427-90 and N427-OC needle set" do
      assert length(KeihinNeedle.data()) == 231
    end

    test "every needle samples a profile from the shank diameter down to the ø1.2 tip" do
      assert Enum.all?(KeihinNeedle.data(), fn n ->
               [root_um | _] = n.station_diameters_um
               tip_um = List.last(n.station_diameters_um)

               n.manufacturer == "keihin" and n.num_clips == 5 and tip_um == 1200 and
                 root_um > tip_um and n.series in ["N427-48", "N427-90", "N427-OC"]
             end)
    end

    test "uses the documented physical length per family for total_length" do
      [pwk_pj] = Enum.filter(KeihinNeedle.data(), &(&1.part_number == "N427-48-AEF"))
      [fcr_small] = Enum.filter(KeihinNeedle.data(), &(&1.part_number == "N427-90-EBR"))
      [fcr_oc] = Enum.filter(KeihinNeedle.data(), &(&1.part_number == "N427-OC-DBK"))

      assert {pwk_pj.total_length_tenths_mm, fcr_small.total_length_tenths_mm,
              fcr_oc.total_length_tenths_mm} == {660, 870, 1047}
    end

    test "anchors the taper at the documented L1 (preserving the straight-shank delay)" do
      needle = Enum.find(KeihinNeedle.data(), &(&1.part_number == "N427-OC-DBK"))

      assert needle.taper_points_tenths_mm == [747]
    end

    test "places the ø2.515 knee at the position the published angle dictates" do
      needle = Enum.find(KeihinNeedle.data(), &(&1.part_number == "N427-OC-DBK"))
      l1_mm = 74.65
      total_mm = 104.7
      step_mm = (total_mm - l1_mm) / (length(needle.station_diameters_um) - 1)
      knee_index = round((88.4 - l1_mm) / step_mm)

      assert_in_delta Enum.at(needle.station_diameters_um, knee_index), 2515, 25
    end

    test "needles that differ only by the published taper angle produce distinct profiles" do
      aef = Enum.find(KeihinNeedle.data(), &(&1.part_number == "N427-48-AEF"))
      cef = Enum.find(KeihinNeedle.data(), &(&1.part_number == "N427-48-CEF"))

      refute aef.station_diameters_um == cef.station_diameters_um
    end
  end

  describe "seed/0" do
    test "loads the keihin needles into the catalog" do
      KeihinNeedle.seed()

      assert length(Catalog.list_needles("keihin")) == 231
    end
  end
end
