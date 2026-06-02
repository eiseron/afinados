defmodule Afinados.Carburetion.Workbench do
  @moduledoc "Persistence of the user's carburetion work, scoped to a garage (the tenant)."

  import Ecto.Query

  alias Afinados.Carburetion.{Catalog, Clip, Shim, Venturi}
  alias Afinados.Carburetion.Setup, as: ResolvedSetup
  alias Afinados.Carburetion.Workbench.{Carburetor, Setup}
  alias Afinados.Garage
  alias Afinados.Repo
  alias Ecto.Multi

  @spec save_setup(Garage.t(), map()) :: {:ok, Setup.t()} | {:error, Ecto.Changeset.t()}
  def save_setup(%Garage{id: garage_id}, params) do
    carburetor =
      Carburetor.changeset(%Carburetor{}, %{
        garage_id: garage_id,
        manufacturer: "mikuni",
        venturi_mm: params["venturi_mm"]
      })

    multi =
      Multi.new()
      |> Multi.insert(:carburetor, carburetor)
      |> Multi.insert(:setup, &setup_changeset(&1, garage_id, params))

    case Repo.transaction(multi) do
      {:ok, %{setup: setup}} -> {:ok, setup}
      {:error, _step, changeset, _changes} -> {:error, changeset}
    end
  end

  @spec list_setups(Garage.t()) :: [Setup.t()]
  def list_setups(%Garage{id: garage_id}) do
    query = from s in Setup, where: s.garage_id == ^garage_id, order_by: [desc: s.id]
    Repo.all(query) |> Repo.preload(:carburetor)
  end

  @spec get_setup(Garage.t(), integer()) :: Setup.t() | nil
  def get_setup(%Garage{id: garage_id}, id) do
    case Repo.get_by(Setup, id: id, garage_id: garage_id) do
      nil -> nil
      setup -> Repo.preload(setup, :carburetor)
    end
  end

  @spec resolve(Setup.t()) :: {:ok, ResolvedSetup.t()} | :error
  def resolve(%Setup{carburetor: %Carburetor{venturi_mm: venturi_mm}} = setup) do
    with {:ok, needle} <- Catalog.fetch_needle(setup.needle_part_number),
         {:ok, needle_jet} <- Catalog.fetch_needle_jet(setup.needle_jet_code) do
      {:ok,
       %ResolvedSetup{
         needle: needle,
         needle_jet: needle_jet,
         clip: %Clip{position: setup.clip_position},
         shim: %Shim{hundredths: setup.shim_hundredths},
         venturi: %Venturi{mm: venturi_mm * 1.0}
       }}
    end
  end

  defp setup_changeset(%{carburetor: carburetor}, garage_id, params) do
    Setup.changeset(%Setup{}, %{
      garage_id: garage_id,
      carburetor_id: carburetor.id,
      needle_part_number: params["part_number"],
      clip_position: params["clip_position"],
      shim_hundredths: params["shim_hundredths"] || 0,
      needle_jet_code: params["needle_jet_code"]
    })
  end
end
