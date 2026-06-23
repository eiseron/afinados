defmodule Afinados.Carburetion.IntakeSizing.VelocityPaletteTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion.IntakeSizing.VelocityPalette

  describe "color_for/1" do
    test "restricting velocity inside the RPM band paints yellow" do
      assert VelocityPalette.color_for(%{velocity: 200, in_band: true}) == "hsl(48, 90%, 55%)"
    end

    test "restricting velocity outside the RPM band paints dark yellow" do
      assert VelocityPalette.color_for(%{velocity: 200, in_band: false}) == "hsl(40, 90%, 32%)"
    end

    test "anemic velocity inside the RPM band paints light blue" do
      assert VelocityPalette.color_for(%{velocity: 50, in_band: true}) == "hsl(205, 80%, 60%)"
    end

    test "anemic velocity outside the RPM band paints dark blue" do
      assert VelocityPalette.color_for(%{velocity: 50, in_band: false}) == "hsl(220, 75%, 30%)"
    end

    test "velocity exactly at the anemic threshold is treated as sufficient" do
      assert VelocityPalette.color_for(%{velocity: 60, in_band: true}) == "hsl(125, 75%, 45%)"
    end

    test "sufficient velocity inside the RPM band paints green" do
      assert VelocityPalette.color_for(%{velocity: 100, in_band: true}) == "hsl(125, 75%, 45%)"
    end

    test "sufficient velocity outside the RPM band paints dark green" do
      assert VelocityPalette.color_for(%{velocity: 100, in_band: false}) == "hsl(125, 70%, 25%)"
    end
  end
end
