defmodule Afinados.OffersTest do
  use Afinados.DataCase, async: true

  alias Afinados.Offers
  alias Afinados.Offers.Offer

  defp offer(attrs) do
    defaults = %{
      provider: "hotmart",
      kind: "course",
      locale: "pt_BR",
      title: "Offer",
      target_url: "https://example.com/x",
      surfaces: ["hub_shelf"],
      position: 0,
      active: true
    }

    struct(Offer, Map.merge(defaults, Map.new(attrs)))
  end

  describe "build_offer_shelf/3" do
    test "keeps only offers assigned to the requested surface" do
      offers = [
        offer(title: "Hub", surfaces: ["hub_shelf"]),
        offer(title: "Simulator", surfaces: ["simulator_shelf"])
      ]

      shelf = Offers.build_offer_shelf(offers, "hub_shelf", "pt_BR")

      assert Enum.map(shelf, & &1.title) == ["Hub"]
    end

    test "keeps only offers matching the requested locale" do
      offers = [
        offer(title: "Portuguese", locale: "pt_BR"),
        offer(title: "English", locale: "en")
      ]

      shelf = Offers.build_offer_shelf(offers, "hub_shelf", "pt_BR")

      assert Enum.map(shelf, & &1.title) == ["Portuguese"]
    end

    test "excludes inactive offers" do
      offers = [
        offer(title: "Live", active: true),
        offer(title: "Retired", active: false)
      ]

      shelf = Offers.build_offer_shelf(offers, "hub_shelf", "pt_BR")

      assert Enum.map(shelf, & &1.title) == ["Live"]
    end

    test "orders offers by ascending position" do
      offers = [
        offer(title: "Third", position: 2),
        offer(title: "First", position: 0),
        offer(title: "Second", position: 1)
      ]

      shelf = Offers.build_offer_shelf(offers, "hub_shelf", "pt_BR")

      assert Enum.map(shelf, & &1.title) == ["First", "Second", "Third"]
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      provider: "aliexpress",
      kind: "part",
      locale: "pt_BR",
      title: "Carburador Nibbi PE28",
      target_url: "https://s.click.aliexpress.com/example",
      surfaces: ["hub_shelf"]
    }

    test "accepts a well-formed affiliate offer" do
      assert Offer.changeset(%Offer{}, @valid_attrs).valid?
    end

    test "rejects an unknown provider" do
      changeset = Offer.changeset(%Offer{}, %{@valid_attrs | provider: "amazon"})

      assert "is invalid" in errors_on(changeset).provider
    end

    test "rejects a surface outside the known set" do
      changeset = Offer.changeset(%Offer{}, %{@valid_attrs | surfaces: ["billboard"]})

      assert "has an invalid entry" in errors_on(changeset).surfaces
    end

    test "rejects every non-https target url scheme" do
      for unsafe <- [
            "http://insecure.example.com",
            "javascript:alert(1)",
            "data:text/html;base64,x",
            "//evil.example.com",
            "/relative/path"
          ] do
        changeset = Offer.changeset(%Offer{}, %{@valid_attrs | target_url: unsafe})

        assert "has invalid format" in errors_on(changeset).target_url,
               "expected #{unsafe} to be rejected as a target url"
      end
    end

    test "rejects a non-https image url to avoid mixed content" do
      changeset =
        Offer.changeset(
          %Offer{},
          Map.put(@valid_attrs, :image_url, "http://cdn.example.com/x.png")
        )

      assert "has invalid format" in errors_on(changeset).image_url
    end
  end
end
