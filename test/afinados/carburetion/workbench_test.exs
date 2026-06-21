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
      "manufacturer" => "mikuni",
      "venturi_mm" => "34",
      "part_number" => "4D3",
      "needle_jet_code" => "159-P4",
      "high_jet_number" => "150",
      "low_jet_number" => "25",
      "clip_position" => "3",
      "shim_hundredths" => "0"
    }
  end

  describe "save_setup/2" do
    test "persists a setup scoped to the garage", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())

      assert setup.garage_id == ctx.garage.id
    end

    test "records the chosen manufacturer on the carburetor", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())

      assert Repo.get!(Workbench.Carburetor, setup.carburetor_id).manufacturer == "mikuni"
    end

    test "rejects a non-positive bore", ctx do
      assert {:error, _changeset} =
               Workbench.save_setup(ctx.garage, Map.put(valid_params(), "venturi_mm", "0"))
    end
  end

  describe "list_setups/1" do
    test "lists the garage's setups with the carburetor preloaded", ctx do
      Workbench.save_setup(ctx.garage, valid_params())

      assert hd(Workbench.list_setups(ctx.garage)).carburetor.venturi_mm == 34
    end
  end

  describe "get_setup/2" do
    test "does not leak a setup across garages", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())
      other = Garage.default_for(Identity.ensure_user_for_token(Identity.generate_token()))

      assert Workbench.get_setup(other, setup.id) == nil
    end
  end

  describe "delete_setup/2" do
    test "removes the setup from the garage", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())
      Workbench.delete_setup(ctx.garage, setup.id)

      assert Workbench.list_setups(ctx.garage) == []
    end

    test "also removes the setup's carburetor", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())
      Workbench.delete_setup(ctx.garage, setup.id)

      assert Repo.aggregate(Workbench.Carburetor, :count) == 0
    end

    test "does not delete a setup belonging to another garage", ctx do
      {:ok, setup} = Workbench.save_setup(ctx.garage, valid_params())
      other = Garage.default_for(Identity.ensure_user_for_token(Identity.generate_token()))
      Workbench.delete_setup(other, setup.id)

      assert Workbench.get_setup(ctx.garage, setup.id)
    end
  end

  describe "resolve/1" do
    test "builds a pure setup (with both jets) that produces the curve", ctx do
      {:ok, saved} = Workbench.save_setup(ctx.garage, valid_params())
      {:ok, resolved} = Workbench.resolve(Workbench.get_setup(ctx.garage, saved.id))

      assert length(Carburetion.build_fuel_map(resolved).points) == 101
    end
  end
end
