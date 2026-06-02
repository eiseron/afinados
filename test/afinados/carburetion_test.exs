defmodule Afinados.CarburetionTest do
  use ExUnit.Case, async: true

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Clip, Needle, NeedleJet, Setup, Shim, Venturi}

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
      clip: %Clip{position: 3},
      shim: %Shim{hundredths: 0},
      venturi: %Venturi{mm: 34.0}
    }

    %{setup: setup}
  end

  describe "build_fuel_map/1" do
    test "produces an area for every throttle position from 0% to 100%", %{setup: setup} do
      positions =
        setup |> Carburetion.build_fuel_map() |> Map.fetch!(:points) |> Enum.map(& &1.position)

      assert positions == Enum.to_list(0..100)
    end

    test "the window spans from h0 to h0 + venturi", %{setup: setup} do
      map = Carburetion.build_fuel_map(setup)

      assert {map.h0, map.h_max} == {3.0, 37.0}
    end

    test "the area grows as the throttle opens", %{setup: setup} do
      areas =
        setup |> Carburetion.build_fuel_map() |> Map.fetch!(:points) |> Enum.map(& &1.free_area)

      assert List.last(areas) > List.first(areas)
    end

    test "the area is non-decreasing across positions", %{setup: setup} do
      areas =
        setup |> Carburetion.build_fuel_map() |> Map.fetch!(:points) |> Enum.map(& &1.free_area)

      assert areas == Enum.sort(areas)
    end

    test "no area exceeds the needle jet bore nor goes negative", %{setup: setup} do
      bore_area = Carburetion.bore_area(setup.needle_jet)
      map = Carburetion.build_fuel_map(setup)

      assert Enum.all?(map.points, &(&1.free_area >= 0.0 and &1.free_area <= bore_area))
    end

    test "marks the needle's unused span beyond the window", %{setup: setup} do
      map = Carburetion.build_fuel_map(setup)

      assert map.unused_span == %{from: 37.0, to: 50.3}
    end

    test "has no unused span when the needle fits within the window", %{setup: setup} do
      map = Carburetion.build_fuel_map(%{setup | venturi: %Venturi{mm: 60.0}})

      assert map.unused_span == nil
    end
  end

  describe "compute_annular_area/2" do
    test "on the straight section equals (pi/4)*(bore^2 - straight^2)", %{setup: setup} do
      expected = :math.pi() / 4 * (2.7 * 2.7 - 2.511 * 2.511)

      assert_in_delta Carburetion.compute_annular_area(setup, 10.0), expected, 0.0001
    end
  end

  describe "h0/1" do
    test "is the clip offset (1 mm per position) plus the shim offset (hundredths)", %{
      setup: setup
    } do
      setup = %{setup | clip: %Clip{position: 3}, shim: %Shim{hundredths: 25}}

      assert Carburetion.h0(setup) == 3.25
    end

    test "raising the clip lifts the whole window", %{setup: setup} do
      lifted = Carburetion.h0(%{setup | clip: %Clip{position: 4}})
      base = Carburetion.h0(%{setup | clip: %Clip{position: 3}})

      assert lifted - base == 1.0
    end
  end
end
