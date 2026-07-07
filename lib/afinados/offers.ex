defmodule Afinados.Offers do
  @moduledoc "Affiliate offers (Hotmart courses, AliExpress parts) shown as curated third-party cards."

  import Ecto.Query

  alias Afinados.Offers.Offer
  alias Afinados.Repo

  @spec list_offers() :: [Offer.t()]
  def list_offers, do: Repo.all(from o in Offer, order_by: [asc: o.position, asc: o.id])

  @spec get_offer!(term()) :: Offer.t()
  def get_offer!(id), do: Repo.get!(Offer, id)

  @spec get_offer(term()) :: Offer.t() | nil
  def get_offer(id), do: Repo.get(Offer, id)

  @spec create_offer(map()) :: {:ok, Offer.t()} | {:error, Ecto.Changeset.t()}
  def create_offer(attrs), do: %Offer{} |> Offer.changeset(attrs) |> Repo.insert()

  @spec update_offer(Offer.t(), map()) :: {:ok, Offer.t()} | {:error, Ecto.Changeset.t()}
  def update_offer(%Offer{} = offer, attrs), do: offer |> Offer.changeset(attrs) |> Repo.update()

  @spec set_offers_active([integer()], boolean()) :: non_neg_integer()
  def set_offers_active(ids, active) when is_list(ids) and is_boolean(active) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    {count, _} =
      from(o in Offer, where: o.id in ^ids)
      |> Repo.update_all(set: [active: active, updated_at: now])

    count
  end

  @spec delete_offer(Offer.t()) :: {:ok, Offer.t()} | {:error, Ecto.Changeset.t()}
  def delete_offer(%Offer{} = offer), do: Repo.delete(offer)

  @spec change_offer(Offer.t(), map()) :: Ecto.Changeset.t()
  def change_offer(%Offer{} = offer, attrs \\ %{}), do: Offer.changeset(offer, attrs)

  @spec build_offer_shelf([Offer.t()], String.t(), String.t()) :: [Offer.t()]
  def build_offer_shelf(offers, surface, locale) do
    offers
    |> Enum.filter(&visible?(&1, surface, locale))
    |> Enum.sort_by(& &1.position)
  end

  defp visible?(offer, surface, locale),
    do: offer.active and offer.locale == locale and surface in offer.surfaces
end
