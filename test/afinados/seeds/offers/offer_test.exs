defmodule Afinados.Seeds.Offers.OfferTest do
  use Afinados.DataCase, async: true

  alias Afinados.Offers
  alias Afinados.Seeds.Offers.Offer, as: OfferSeed

  describe "seed/0" do
    test "inserts every example offer" do
      OfferSeed.seed()

      assert length(Offers.list_offers()) == length(OfferSeed.data())
    end

    test "seeds a curated Nibbi part offer for the Brazilian audience" do
      OfferSeed.seed()

      titles =
        Offers.list_offers()
        |> Enum.filter(&(&1.locale == "pt_BR"))
        |> Enum.map(& &1.title)

      assert "Carburador Nibbi PE28" in titles
    end
  end
end
