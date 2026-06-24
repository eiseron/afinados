defmodule Afinados.Carburetion.IntakeSizing.VelocityPaletteTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing.VelocityPalette

  @stock_thresholds {35.0, 95.0}

  describe "thresholds/1" do
    test "spreads the band evenly around the target velocity" do
      assert VelocityPalette.thresholds(65.0) == {65.0 - 30.0, 65.0 + 30.0}
    end

    test "shifts the anemic edge by the target-velocity delta" do
      {anemic_low, _} = VelocityPalette.thresholds(50.0)
      {anemic_high, _} = VelocityPalette.thresholds(120.0)

      assert anemic_high - anemic_low == 70.0
    end

    test "shifts the restriction edge by the same target-velocity delta" do
      {_, restriction_low} = VelocityPalette.thresholds(50.0)
      {_, restriction_high} = VelocityPalette.thresholds(120.0)

      assert restriction_high - restriction_low == 70.0
    end
  end

  describe "color_for/1 — restriction" do
    test "above the restriction threshold and inside the RPM band paints yellow" do
      assert VelocityPalette.color_for(%{
               velocity: 150,
               in_band: true,
               thresholds: @stock_thresholds
             }) == "hsl(48, 90%, 55%)"
    end

    test "above the restriction threshold and outside the RPM band paints dark yellow" do
      assert VelocityPalette.color_for(%{
               velocity: 150,
               in_band: false,
               thresholds: @stock_thresholds
             }) == "hsl(40, 90%, 32%)"
    end
  end

  describe "color_for/1 — anemic" do
    test "below the anemic threshold and inside the RPM band paints light blue" do
      assert VelocityPalette.color_for(%{
               velocity: 20,
               in_band: true,
               thresholds: @stock_thresholds
             }) == "hsl(205, 80%, 60%)"
    end

    test "below the anemic threshold and outside the RPM band paints dark blue" do
      assert VelocityPalette.color_for(%{
               velocity: 20,
               in_band: false,
               thresholds: @stock_thresholds
             }) == "hsl(220, 75%, 30%)"
    end
  end

  describe "color_for/1 — sufficient" do
    test "inside the band and inside the RPM band paints vivid green" do
      assert VelocityPalette.color_for(%{
               velocity: 65,
               in_band: true,
               thresholds: @stock_thresholds
             }) == "hsl(125, 75%, 45%)"
    end

    test "inside the band and outside the RPM band paints dark green" do
      assert VelocityPalette.color_for(%{
               velocity: 65,
               in_band: false,
               thresholds: @stock_thresholds
             }) == "hsl(125, 70%, 25%)"
    end
  end

  describe "color_for/1 — K-aware thresholds shift the color of a boundary velocity" do
    test "velocity of 100 m/s is anemic for a race-tuned car (target 65 m/s, band 35–95)" do
      race_car = VelocityPalette.thresholds(65.0)

      assert VelocityPalette.color_for(%{velocity: 100, in_band: true, thresholds: race_car}) ==
               "hsl(48, 90%, 55%)"
    end

    test "velocity of 100 m/s is sufficient for a stock car (target 88 m/s, band 58–118)" do
      stock_car = VelocityPalette.thresholds(88.0)

      assert VelocityPalette.color_for(%{velocity: 100, in_band: true, thresholds: stock_car}) ==
               "hsl(125, 75%, 45%)"
    end
  end

  describe "thresholds/2 — induction-aware" do
    test "injection widens the band on the low end (atomization is irrelevant)" do
      target = 95.0
      {anemic_carb, _} = VelocityPalette.thresholds(target, :carburetor)
      {anemic_efi, _} = VelocityPalette.thresholds(target, :injection)

      assert anemic_efi < anemic_carb
    end

    test "injection keeps the same restriction edge (same physical flow limit)" do
      target = 95.0
      {_, restriction_carb} = VelocityPalette.thresholds(target, :carburetor)
      {_, restriction_efi} = VelocityPalette.thresholds(target, :injection)

      assert_in_delta restriction_efi, restriction_carb, 1.0e-9
    end

    test "injection band is 70 m/s wide (vs 60 m/s for carburetor)" do
      target = 95.0
      {anemic_efi, restriction_efi} = VelocityPalette.thresholds(target, :injection)

      assert_in_delta restriction_efi - anemic_efi, 70.0, 1.0e-9
    end

    test "default (no induction arg) matches :carburetor" do
      assert VelocityPalette.thresholds(95.0) == VelocityPalette.thresholds(95.0, :carburetor)
    end
  end
end
