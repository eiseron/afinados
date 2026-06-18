defmodule Afinados.Carburetion.ManufacturerTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.Manufacturer

  describe "all/0 and default/0" do
    test "the default manufacturer is among the known ones" do
      assert Manufacturer.default() in Manufacturer.all()
    end

    test "every known manufacturer is recognised" do
      assert Enum.all?(Manufacturer.all(), &Manufacturer.known?/1)
    end

    test "an unknown manufacturer is not recognised" do
      refute Manufacturer.known?("rochester")
    end
  end

  describe "high_jet_area/2" do
    test "derives the area from the nominal diameter (number/100 mm)" do
      assert_in_delta Manufacturer.high_jet_area("mikuni", 150),
                      :math.pi() / 4 * 1.5 * 1.5,
                      0.0001
    end
  end

  describe "low_jet_area/2" do
    test "is linear in the jet number for a manufacturer" do
      assert_in_delta Manufacturer.low_jet_area("mikuni", 50),
                      2 * Manufacturer.low_jet_area("mikuni", 25),
                      0.0001
    end

    test "falls back to the default parametrisation for an unknown manufacturer" do
      assert Manufacturer.low_jet_area("rochester", 25) == Manufacturer.low_jet_area("mikuni", 25)
    end
  end
end
