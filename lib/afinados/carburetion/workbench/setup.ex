defmodule Afinados.Carburetion.Workbench.Setup do
  @moduledoc "Persisted setup (the acerto): the catalog parts chosen for a carburetor, owned by a garage."

  use Ecto.Schema

  import Ecto.Changeset

  alias Afinados.Carburetion.Workbench.Carburetor
  alias Afinados.Garage

  @fields [
    :garage_id,
    :carburetor_id,
    :label,
    :needle_part_number,
    :clip_position,
    :shim_hundredths,
    :needle_jet_code
  ]
  @required [:garage_id, :carburetor_id, :needle_part_number, :clip_position, :needle_jet_code]

  schema "setups" do
    field :label, :string
    field :needle_part_number, :string
    field :clip_position, :integer
    field :shim_hundredths, :integer, default: 0
    field :needle_jet_code, :string
    belongs_to :garage, Garage
    belongs_to :carburetor, Carburetor

    timestamps()
  end

  def changeset(setup, attrs) do
    setup
    |> cast(attrs, @fields)
    |> validate_required(@required)
    |> validate_number(:clip_position, greater_than_or_equal_to: 1)
    |> validate_number(:shim_hundredths, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:needle_part_number)
    |> foreign_key_constraint(:needle_jet_code)
    |> foreign_key_constraint(:carburetor_id)
    |> foreign_key_constraint(:garage_id)
  end

  @type t :: %__MODULE__{}
end
