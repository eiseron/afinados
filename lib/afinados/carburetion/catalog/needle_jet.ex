defmodule Afinados.Carburetion.Catalog.NeedleJet do
  @moduledoc "Catalog record for a needle jet (bore in micrometers)."

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:code, :manufacturer, :bore_um]

  schema "needle_jets" do
    field :code, :string
    field :manufacturer, :string
    field :bore_um, :integer

    timestamps()
  end

  @type t :: %__MODULE__{}

  def changeset(needle_jet, attrs) do
    needle_jet
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_number(:bore_um, greater_than: 0)
    |> unique_constraint(:code)
  end
end
