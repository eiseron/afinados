defmodule Afinados.Carburetion.CatalogTest do
  use Afinados.DataCase, async: true

  alias Afinados.Carburetion

  alias Afinados.Carburetion.{
    Catalog,
    Clip,
    HighJet,
    LowJet,
    Needle,
    NeedleJet,
    Setup,
    Shim,
    Venturi
  }

  alias Afinados.Repo

  defp seed_needle do
    %Catalog.Needle{}
    |> Catalog.Needle.changeset(%{
      part_number: "4D3",
      manufacturer: "mikuni",
      total_length_tenths_mm: 503,
      taper_points_tenths_mm: [253],
      station_diameters_um: [2511, 2511, 2421, 2253, 2100],
      num_clips: 5
    })
    |> Repo.insert!()
  end

  defp seed_needle_jet do
    %Catalog.NeedleJet{}
    |> Catalog.NeedleJet.changeset(%{code: "159-P4", manufacturer: "mikuni", bore_um: 2700})
    |> Repo.insert!()
  end

  defp seed_keihin_needle do
    %Catalog.Needle{}
    |> Catalog.Needle.changeset(%{
      part_number: "90DT",
      manufacturer: "keihin",
      total_length_tenths_mm: 503,
      taper_points_tenths_mm: [253],
      station_diameters_um: [2511, 2511, 2421, 2253, 2100],
      num_clips: 5
    })
    |> Repo.insert!()
  end

  describe "fetch_needle/2" do
    test "resolves the catalog record into a pure needle in millimeters" do
      seed_needle()

      assert {:ok,
              %Needle{
                part_number: "4D3",
                total_length_mm: 50.3,
                taper_points_mm: [25.3],
                station_diameters_mm: [2.511, 2.511, 2.421, 2.253, 2.1],
                num_clips: 5
              }} = Catalog.fetch_needle("mikuni", "4D3")
    end

    test "returns :error for an unknown part number" do
      assert Catalog.fetch_needle("mikuni", "nope") == :error
    end

    test "returns :error for a nil part number without querying" do
      assert Catalog.fetch_needle("mikuni", nil) == :error
    end
  end

  describe "fetch_needle_jet/2" do
    test "resolves the bore from micrometers into millimeters" do
      seed_needle_jet()

      assert {:ok, %NeedleJet{code: "159-P4", bore_mm: 2.7}} =
               Catalog.fetch_needle_jet("mikuni", "159-P4")
    end

    test "returns :error for an unknown code" do
      assert Catalog.fetch_needle_jet("mikuni", "nope") == :error
    end

    test "returns :error for a nil code without querying" do
      assert Catalog.fetch_needle_jet("mikuni", nil) == :error
    end
  end

  describe "scoping by manufacturer" do
    test "list_needles/1 returns only the manufacturer's needles" do
      seed_needle()
      seed_keihin_needle()

      assert Enum.map(Catalog.list_needles("mikuni"), & &1.part_number) == ["4D3"]
    end

    test "list_manufacturers/0 lists the distinct seeded manufacturers" do
      seed_needle()
      seed_keihin_needle()

      assert Catalog.list_manufacturers() == ["keihin", "mikuni"]
    end
  end

  test "resolves catalog integer units end-to-end into the computed annular area (mm/mm²)" do
    seed_needle()
    seed_needle_jet()
    {:ok, needle} = Catalog.fetch_needle("mikuni", "4D3")
    {:ok, needle_jet} = Catalog.fetch_needle_jet("mikuni", "159-P4")

    setup = %Setup{
      needle: needle,
      needle_jet: needle_jet,
      high_jet: %HighJet{number: 150, free_area_mm2: 1.0},
      low_jet: %LowJet{number: 25.0, free_area_mm2: 0.125},
      clip: %Clip{position: 3},
      shim: %Shim{hundredths: 0},
      venturi: %Venturi{mm: 34.0}
    }

    assert_in_delta Carburetion.compute_annular_area(setup, Carburetion.h0(setup)),
                    :math.pi() / 4 * (2.7 * 2.7 - 2.511 * 2.511),
                    0.0001
  end
end
