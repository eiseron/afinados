defmodule Afinados.Carburetion.WorkbenchTest do
  use Afinados.DataCase, async: true

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Catalog, Workbench}
  alias Afinados.{Garage, Identity, Repo}

  setup do
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

    %Catalog.NeedleJet{}
    |> Catalog.NeedleJet.changeset(%{code: "159-P4", manufacturer: "mikuni", bore_um: 2700})
    |> Repo.insert!()

    garage = Garage.default_for(Identity.ensure_user_for_token(Identity.generate_token()))
    %{garage: garage}
  end

  defp valid_params do
    %{
      "venturi_mm" => "34",
      "part_number" => "4D3",
      "needle_jet_code" => "159-P4",
      "clip_position" => "3",
      "shim_hundredths" => "0"
    }
  end

  describe "save_setup/2" do
    test "persists a setup scoped to the garage", %{garage: garage} do
      {:ok, setup} = Workbench.save_setup(garage, valid_params())

      assert setup.garage_id == garage.id
    end

    test "rejects a non-positive venturi", %{garage: garage} do
      assert {:error, _changeset} =
               Workbench.save_setup(garage, Map.put(valid_params(), "venturi_mm", "0"))
    end
  end

  describe "list_setups/1" do
    test "lists the garage's setups with the carburetor preloaded", %{garage: garage} do
      Workbench.save_setup(garage, valid_params())

      assert hd(Workbench.list_setups(garage)).carburetor.venturi_mm == 34
    end
  end

  describe "get_setup/2" do
    test "does not leak a setup across garages" do
      garage = Garage.default_for(Identity.ensure_user_for_token(Identity.generate_token()))
      {:ok, setup} = Workbench.save_setup(garage, valid_params())
      other = Garage.default_for(Identity.ensure_user_for_token(Identity.generate_token()))

      assert Workbench.get_setup(other, setup.id) == nil
    end
  end

  describe "resolve/1" do
    test "builds a pure setup that produces the curve", %{garage: garage} do
      {:ok, saved} = Workbench.save_setup(garage, valid_params())
      {:ok, resolved} = Workbench.resolve(Workbench.get_setup(garage, saved.id))

      assert length(Carburetion.build_fuel_map(resolved).points) == 101
    end
  end
end
