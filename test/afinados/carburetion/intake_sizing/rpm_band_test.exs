defmodule Afinados.Carburetion.IntakeSizing.RpmBandTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing.RpmBand

  describe "range/1" do
    test "motorcycles span 2.5k to 14k RPM" do
      assert RpmBand.range("motorcycle") == {2500, 14_000}
    end

    test "mopeds span 3k to 10k RPM" do
      assert RpmBand.range("moped") == {3000, 10_000}
    end

    test "high-revving power tools span 6k to 13k RPM" do
      assert RpmBand.range("tool") == {6000, 13_000}
    end

    test "stationary engines sit around the synchronous 3000-3600 rpm window" do
      assert RpmBand.range("stationary") == {2900, 3700}
    end

    test "cars span 1.5k to 6.5k RPM" do
      assert RpmBand.range("car") == {1500, 6500}
    end

    test "falls back to a generic band for unknown vehicles" do
      assert RpmBand.range("unknown") == {2000, 8000}
    end
  end

  describe "center/1" do
    test "returns the midpoint of the car band" do
      assert RpmBand.center("car") == 4000.0
    end

    test "returns the midpoint of the motorcycle band" do
      assert RpmBand.center("motorcycle") == 8250.0
    end

    test "returns the midpoint of the stationary band" do
      assert RpmBand.center("stationary") == 3300.0
    end
  end

  describe "overlaps?/2" do
    test "true when the window straddles the band" do
      assert RpmBand.overlaps?("car", {3000, 5000}) == true
    end

    test "true when the window sits entirely inside the band" do
      assert RpmBand.overlaps?("car", {2500, 5500}) == true
    end

    test "false when the window is entirely above the band" do
      assert RpmBand.overlaps?("car", {7000, 10_000}) == false
    end

    test "false when the window is entirely below the band" do
      assert RpmBand.overlaps?("car", {500, 1000}) == false
    end
  end
end
