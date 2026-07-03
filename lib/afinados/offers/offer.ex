defmodule Afinados.Offers.Offer do
  @moduledoc "A curated affiliate offer (Hotmart course or AliExpress part) shown as a third-party card."

  use Ecto.Schema

  import Ecto.Changeset

  @providers ~w(hotmart aliexpress)
  @kinds ~w(course part)
  @surfaces ~w(hub_shelf simulator_shelf jet_suggestion)

  schema "offers" do
    field :provider, :string
    field :kind, :string
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

  @required ~w(provider kind locale title target_url)a
  @optional ~w(description image_url context_tags surfaces position active)a

  @type t :: %__MODULE__{}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(offer, attrs) do
    offer
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:provider, @providers)
    |> validate_inclusion(:kind, @kinds)
    |> validate_subset(:surfaces, @surfaces)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> validate_format(:target_url, ~r{^https://})
    |> validate_format(:image_url, ~r{^https://})
  end
end
