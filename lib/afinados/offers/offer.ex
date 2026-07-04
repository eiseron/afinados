defmodule Afinados.Offers.Offer do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @surfaces ~w(hub_shelf)

  schema "offers" do
    field :locale, :string
    field :title, :string
    field :description, :string
    field :image_url, :string
    field :target_url, :string
    field :context_tags, {:array, :string}, default: []
    field :surfaces, {:array, :string}, default: []
    field :position, :integer, default: 0
    field :active, :boolean, default: true

    timestamps()
  end

  @required ~w(locale title target_url)a
  @optional ~w(description image_url context_tags surfaces position active)a

  @type t :: %__MODULE__{}

  @spec surfaces() :: [String.t()]
  def surfaces, do: @surfaces

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(offer, attrs) do
    offer
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_subset(:surfaces, @surfaces)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> validate_format(:target_url, ~r{^https://})
    |> validate_format(:image_url, ~r{^https://})
  end
end
