defmodule Afinados.Seeds.Carburetion.KeihinNeedleJet do
  @moduledoc "Frozen Keihin needle-jet reference data. FCR/PWK have no replaceable needle jet; the needle rides in a fixed ~2.9mm main-nozzle bore (measured on PWK, matches the ø2.9 upper shaft on the official needle diagrams)."

  alias Afinados.Carburetion.Catalog
  alias Afinados.Repo

  @needle_jets [
    %{code: "FCR/PWK 2.9mm", manufacturer: "keihin", bore_um: 2900}
  ]

  @spec data() :: [map()]
  def data, do: @needle_jets

  @spec seed() :: :ok
  def seed do
    Enum.each(data(), fn attrs ->
      %Catalog.NeedleJet{}
      |> Catalog.NeedleJet.changeset(attrs)
      |> Repo.insert!(
        on_conflict: {:replace_all_except, [:id, :inserted_at]},
        conflict_target: :code
      )
    end)
  end
end
