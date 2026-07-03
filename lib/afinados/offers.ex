defmodule Afinados.Offers do
  @moduledoc "Affiliate offers (Hotmart courses, AliExpress parts) shown as curated third-party cards."

  import Ecto.Query

  alias Afinados.Offers.Offer
  alias Afinados.Repo

  @spec list_offers() :: [Offer.t()]
  def list_offers, do: Repo.all(from o in Offer, order_by: [asc: o.position, asc: o.id])

  @spec build_offer_shelf([Offer.t()], String.t(), String.t()) :: [Offer.t()]
  def build_offer_shelf(offers, surface, locale) do
    offers
    |> Enum.filter(&visible?(&1, surface, locale))
    |> Enum.sort_by(& &1.position)
  end

  defp visible?(offer, surface, locale),
    do: offer.active and offer.locale == locale and surface in offer.surfaces
end
