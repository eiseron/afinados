defmodule Afinados.CarburetionTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Clip, HighJet, LowJet, Needle, NeedleJet, Setup, Shim, Venturi}

  setup do
    setup = %Setup{
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

    %{setup: setup}
  end

  defp areas(setup) do
    setup |> Carburetion.build_fuel_map() |> Map.fetch!(:points) |> Enum.map(& &1.free_area)
  end

  describe "build_fuel_map/1" do
    test "produces an area for every throttle position from 0% to 100%", %{setup: setup} do
      positions =
        setup |> Carburetion.build_fuel_map() |> Map.fetch!(:points) |> Enum.map(& &1.position)

      assert positions == Enum.to_list(0..100)
    end

    test "the window spans h0 to h0 + venturi, anchored at the taper start", %{setup: setup} do
      map = Carburetion.build_fuel_map(setup)

      assert {Float.round(map.h0, 4), Float.round(map.h_max, 4)} == {28.3, 62.3}
    end

    test "at idle (0%) the free area is the idle effective plus the pilot floor", %{setup: setup} do
      expected =
        Carburetion.compute_effective_area(setup, Carburetion.h0(setup)) +
          setup.low_jet.free_area_mm2

      assert_in_delta List.first(areas(setup)), expected, 1.0e-9
    end

    test "no point falls below the pilot floor", %{setup: setup} do
      assert Enum.all?(areas(setup), &(&1 >= setup.low_jet.free_area_mm2))
    end

    test "the area grows as the throttle opens", %{setup: setup} do
      assert List.last(areas(setup)) > List.first(areas(setup))
    end

    test "the area is non-decreasing across positions", %{setup: setup} do
      assert areas(setup) == Enum.sort(areas(setup))
    end

    test "marks the needle's unused span at the top (inside the slide)", %{setup: setup} do
      assert Carburetion.build_fuel_map(setup).unused_span == %{from: 0.0, to: 28.3}
    end

    test "a bigger venturi extends the window's end, not its start", %{setup: setup} do
      small = Carburetion.build_fuel_map(setup)
      big = Carburetion.build_fuel_map(%{setup | venturi: %Venturi{mm: 44.0}})

      assert {big.h0 == small.h0, big.h_max > small.h_max} == {true, true}
    end
  end

  describe "compute_annular_area/2" do
    test "on the straight section equals (pi/4)*(bore^2 - straight^2)", %{setup: setup} do
      assert_in_delta Carburetion.compute_annular_area(setup, 10.0),
                      :math.pi() / 4 * (2.7 * 2.7 - 2.511 * 2.511),
                      0.0001
    end

    test "never exceeds the needle jet bore", %{setup: setup} do
      bore_area = Carburetion.bore_area(setup.needle_jet)

      annular =
        Enum.map(
          0..100,
          &Carburetion.compute_annular_area(setup, setup.clip.position + &1 * 0.34)
        )

      assert Enum.all?(annular, &(&1 <= bore_area))
    end
  end

  describe "compute_effective_area/2 (series restriction)" do
    test "never exceeds the main jet area", %{setup: setup} do
      effective = Enum.map(0..100, &Carburetion.compute_effective_area(setup, 3.0 + &1 * 0.34))

      assert Enum.all?(effective, &(&1 < setup.high_jet.free_area_mm2))
    end

    test "never exceeds the annular area", %{setup: setup} do
      below? = fn h ->
        Carburetion.compute_effective_area(setup, h) < Carburetion.compute_annular_area(setup, h)
      end

      assert Enum.all?(Enum.map(0..100, &(3.0 + &1 * 0.34)), below?)
    end
  end

  describe "compute_free_area/2 (pilot floor)" do
    test "at idle equals the effective area at h0 plus the pilot floor", %{setup: setup} do
      idle_effective = Carburetion.compute_effective_area(setup, Carburetion.h0(setup))

      assert_in_delta Carburetion.compute_free_area(setup, Carburetion.h0(setup)),
                      idle_effective + setup.low_jet.free_area_mm2,
                      1.0e-9
    end

    test "a bigger pilot raises every position by the same constant", %{setup: setup} do
      richer = %{setup | low_jet: %LowJet{number: 50.0, free_area_mm2: 0.25}}

      diffs =
        Enum.map(0..100, fn p ->
          Carburetion.compute_free_area(richer, 3.0 + p * 0.34) -
            Carburetion.compute_free_area(setup, 3.0 + p * 0.34)
        end)

      assert Enum.all?(diffs, &(abs(&1 - 0.125) < 1.0e-9))
    end
  end

  describe "h0/1" do
    test "anchors the idle position at the taper start (offset by clip/shim)", %{
      setup: setup
    } do
      assert_in_delta Carburetion.h0(setup), 25.3 + 3.0, 1.0e-9
    end

    test "raising the clip lifts the whole window", %{setup: setup} do
      lifted = Carburetion.h0(%{setup | clip: %Clip{position: 4}})
      base = Carburetion.h0(%{setup | clip: %Clip{position: 3}})

      assert lifted - base == 1.0
    end
  end

  describe "build_high_jet/2" do
    test "derives the area from the nominal diameter (number/100 mm)" do
      assert_in_delta Carburetion.build_high_jet("mikuni", 150).free_area_mm2,
                      :math.pi() / 4 * 1.5 * 1.5,
                      0.0001
    end
  end

  describe "build_low_jet/2" do
    test "area is linear in the flow number" do
      assert_in_delta Carburetion.build_low_jet("mikuni", 50).free_area_mm2,
                      2 * Carburetion.build_low_jet("mikuni", 25).free_area_mm2,
                      0.0001
    end
  end
end
