defmodule Afinados.OffersTest do
  use Afinados.DataCase, async: true

  alias Afinados.Offers
  alias Afinados.Offers.Offer

  defp offer(attrs) do
    defaults = %{
      locale: "pt_BR",
      title: "Offer",
      target_url: "https://example.com/x",
      surfaces: ["hub_shelf"],
      position: 0,
      active: true
    }

    struct(Offer, Map.merge(defaults, Map.new(attrs)))
  end

  defp persisted_attrs(attrs \\ %{}) do
    Map.merge(
      %{
        locale: "pt_BR",
        title: "Offer",
        target_url: "https://example.com/x",
        surfaces: ["hub_shelf"],
        position: 0,
        active: true
      },
      Map.new(attrs)
    )
  end

  describe "build_offer_shelf/3" do
    test "keeps only offers assigned to the requested surface" do
      offers = [
        offer(title: "Hub", surfaces: ["hub_shelf"]),
        offer(title: "Other", surfaces: [])
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

  describe "list_offers/0" do
    test "returns offers ordered by position then id" do
      {:ok, third} = Offers.create_offer(persisted_attrs(title: "Third", position: 5))
      {:ok, first} = Offers.create_offer(persisted_attrs(title: "First", position: 1))
      {:ok, second} = Offers.create_offer(persisted_attrs(title: "Second", position: 1))

      assert Enum.map(Offers.list_offers(), & &1.id) == [first.id, second.id, third.id]
    end
  end

  describe "create_offer/1" do
    test "persists a valid offer" do
      {:ok, offer} = Offers.create_offer(persisted_attrs(title: "Nibbi PE28"))

      assert offer.title == "Nibbi PE28"
    end

    test "returns an invalid changeset for missing required fields" do
      {:error, changeset} = Offers.create_offer(%{title: "No URL"})

      assert "can't be blank" in errors_on(changeset).target_url
    end
  end

  describe "update_offer/2" do
    test "changes stored attributes" do
      {:ok, offer} = Offers.create_offer(persisted_attrs(title: "Old"))
      {:ok, updated} = Offers.update_offer(offer, %{title: "New"})

      assert updated.title == "New"
    end
  end

  describe "delete_offer/1" do
    test "removes the offer" do
      {:ok, offer} = Offers.create_offer(persisted_attrs())
      {:ok, _} = Offers.delete_offer(offer)

      assert Offers.list_offers() == []
    end
  end

  describe "set_offers_active/2" do
    test "returns the number of offers changed" do
      {:ok, a} = Offers.create_offer(persisted_attrs(active: false))
      {:ok, b} = Offers.create_offer(persisted_attrs(active: false))

      assert Offers.set_offers_active([a.id, b.id], true) == 2
    end

    test "activates the selected offers when active is true" do
      {:ok, offer} = Offers.create_offer(persisted_attrs(active: false))

      Offers.set_offers_active([offer.id], true)

      assert Offers.get_offer(offer.id).active
    end

    test "deactivates the selected offers when active is false" do
      {:ok, offer} = Offers.create_offer(persisted_attrs(active: true))

      Offers.set_offers_active([offer.id], false)

      refute Offers.get_offer(offer.id).active
    end

    test "leaves offers outside the id list untouched" do
      {:ok, selected} = Offers.create_offer(persisted_attrs(active: false))
      {:ok, other} = Offers.create_offer(persisted_attrs(active: false))

      Offers.set_offers_active([selected.id], true)

      refute Offers.get_offer(other.id).active
    end
  end

  describe "change_offer/2" do
    test "returns a changeset for the given offer" do
      assert %Ecto.Changeset{} = Offers.change_offer(%Offer{})
    end

    test "marks the changeset invalid for a missing title" do
      changeset = Offers.change_offer(%Offer{}, %{title: ""})

      refute changeset.valid?
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      locale: "pt_BR",
      title: "Carburador Nibbi PE28",
      target_url: "https://s.click.aliexpress.com/example",
      surfaces: ["hub_shelf"]
    }

    test "accepts a well-formed affiliate offer" do
      assert Offer.changeset(%Offer{}, @valid_attrs).valid?
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
