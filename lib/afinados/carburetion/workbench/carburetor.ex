defmodule Afinados.Carburetion.Workbench.Carburetor do
  @moduledoc "Persisted carburetor body, owned by a garage."

  use Ecto.Schema

  import Ecto.Changeset

  alias Afinados.Garage

  @fields [:garage_id, :manufacturer, :venturi_mm, :model_ref, :label]
  @required [:garage_id, :manufacturer, :venturi_mm]

  schema "carburetors" do
    field :manufacturer, :string
    field :venturi_mm, :integer
    field :model_ref, :string
    field :label, :string
    belongs_to :garage, Garage

    timestamps()
  end

  @type t :: %__MODULE__{}

  def changeset(carburetor, attrs) do
    carburetor
    |> cast(attrs, @fields)
    |> validate_required(@required)
    |> validate_number(:venturi_mm, greater_than: 0)
    |> foreign_key_constraint(:garage_id)
  end
end
