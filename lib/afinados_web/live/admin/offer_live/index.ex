defmodule AfinadosWeb.Admin.OfferLive.Index do
  @moduledoc false

  use AfinadosWeb, :live_view

  alias Afinados.Offers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, offers: Offers.list_offers())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="admin">
      <Layouts.flash_group flash={@flash} />
      <h1>{gettext("Offers")}</h1>

      <.link navigate={~p"/admin/offers/new"} class="button">{gettext("New offer")}</.link>

      <table class="admin-table">
        <thead>
          <tr>
            <th scope="col">{gettext("Position")}</th>
            <th scope="col">{gettext("Title")}</th>
            <th scope="col">{gettext("Locale")}</th>
            <th scope="col">{gettext("Active")}</th>
            <th scope="col"><span class="sr-only">{gettext("Actions")}</span></th>
          </tr>
        </thead>
        <tbody>
          <tr :for={offer <- @offers} id={"offer-#{offer.id}"}>
            <td>{offer.position}</td>
            <td>{offer.title}</td>
            <td>{offer.locale}</td>
            <td>{if offer.active, do: gettext("yes"), else: gettext("no")}</td>
            <td>
              <.link navigate={~p"/admin/offers/#{offer}/edit"}>{gettext("Edit")}</.link>
              <button
                type="button"
                class="link-button"
                phx-click="delete"
                phx-value-id={offer.id}
                data-confirm={gettext("Delete this offer?")}
              >
                {gettext("Delete")}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </main>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {int_id, ""} <- Integer.parse(id),
         %Offers.Offer{} = offer <- Offers.get_offer(int_id),
         {:ok, _} <- Offers.delete_offer(offer) do
      {:noreply,
       socket
       |> put_flash(:info, gettext("Offer deleted"))
       |> assign(offers: Offers.list_offers())}
    else
      _ -> {:noreply, put_flash(socket, :error, gettext("Could not delete offer"))}
    end
  end
end
