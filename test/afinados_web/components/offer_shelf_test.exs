defmodule AfinadosWeb.Components.OfferShelfTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias Afinados.Offers.Offer
  alias AfinadosWeb.Components.OfferShelf

  defp offer(attrs \\ %{}) do
    Map.merge(
      %Offer{title: "Carburador", target_url: "https://example.com", image_url: nil},
      Map.new(attrs)
    )
  end

  test "renders the offer image_url when no image slot is given" do
    assigns = %{offer: offer(%{image_url: "https://cdn.example/nibbi.png"})}

    html = rendered_to_string(~H"<OfferShelf.offer_card offer={@offer} />")

    assert html =~ ~s{src="https://cdn.example/nibbi.png"}
  end

  test "renders a placeholder when the offer has no image and no slot" do
    assigns = %{offer: offer()}

    html = rendered_to_string(~H"<OfferShelf.offer_card offer={@offer} />")

    assert html =~ "offer-image-placeholder"
  end

  test "renders the image slot when given" do
    assigns = %{offer: offer(%{image_url: "https://cdn.example/nibbi.png"})}

    html =
      rendered_to_string(~H"""
      <OfferShelf.offer_card offer={@offer}>
        <:image><span class="pending-upload">preview</span></:image>
      </OfferShelf.offer_card>
      """)

    assert html =~ "pending-upload"
  end

  test "hides the offer image_url when the image slot overrides it" do
    assigns = %{offer: offer(%{image_url: "https://cdn.example/nibbi.png"})}

    html =
      rendered_to_string(~H"""
      <OfferShelf.offer_card offer={@offer}>
        <:image><span class="pending-upload">preview</span></:image>
      </OfferShelf.offer_card>
      """)

    refute html =~ ~s{src="https://cdn.example/nibbi.png"}
  end
end
