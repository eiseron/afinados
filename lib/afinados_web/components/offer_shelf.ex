defmodule AfinadosWeb.Components.OfferShelf do
  @moduledoc "Renders the affiliate-offer shelf: curated third-party cards with an affiliation disclosure."

  use Phoenix.Component
  use Gettext, backend: AfinadosWeb.Gettext

  alias Afinados.Offers.Offer

  attr :offers, :list, required: true

  @spec offer_shelf(map()) :: Phoenix.LiveView.Rendered.t()
  def offer_shelf(assigns) do
    ~H"""
    <section :if={@offers != []} class="offers" aria-labelledby="offers-heading">
      <h2 id="offers-heading">{gettext("Recommended for you")}</h2>
      <p class="offers-disclosure">
        {gettext(
          "Third-party products we selected for you. They are not Afinados products, and we may earn a commission if you buy through these links."
        )}
      </p>
      <ul class="offer-list">
        <li :for={offer <- @offers}>
          <.offer_card offer={offer} />
        </li>
      </ul>
    </section>
    """
  end

  attr :offer, Offer, required: true

  @spec offer_card(map()) :: Phoenix.LiveView.Rendered.t()
  def offer_card(assigns) do
    ~H"""
    <article class="offer-card">
      <a
        href={@offer.target_url}
        target="_blank"
        rel="sponsored nofollow noopener external"
        class="offer-link"
      >
        <span class="offer-external" role="img" aria-label={gettext("opens an external site")}>
          <svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true" focusable="false">
            <path
              d="M14 4h6v6M20 4l-9 9M19 14v4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h4"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </span>
        <img
          :if={@offer.image_url}
          src={@offer.image_url}
          alt=""
          class="offer-image"
          loading="lazy"
        />
        <span :if={!@offer.image_url} class="offer-image offer-image-placeholder" aria-hidden="true" />
        <h3 class="offer-title">{@offer.title}</h3>
        <p :if={@offer.description} class="offer-description">{@offer.description}</p>
        <span class="offer-cta">{gettext("View product")}</span>
      </a>
    </article>
    """
  end
end
