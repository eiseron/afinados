defmodule Afinados.Carburetion.Catalog.Needle do
  @moduledoc "Catalog record for a jet needle (integer units: tenths of mm, micrometers)."

  use Ecto.Schema

  import Ecto.Changeset

  @fields [
    :part_number,
    :manufacturer,
    :total_length_tenths_mm,
    :taper_points_tenths_mm,
    :station_diameters_um,
    :num_clips
  ]

  schema "needles" do
    field :part_number, :string
    field :manufacturer, :string
    field :total_length_tenths_mm, :integer
    field :taper_points_tenths_mm, {:array, :integer}
    field :station_diameters_um, {:array, :integer}
    field :num_clips, :integer

    timestamps()
  end

  def changeset(needle, attrs) do
    needle
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_number(:num_clips, greater_than: 0)
    |> validate_length(:taper_points_tenths_mm, min: 1)
    |> validate_length(:station_diameters_um, min: 2)
    |> unique_constraint(:part_number)
  end

  @type t :: %__MODULE__{}
end
