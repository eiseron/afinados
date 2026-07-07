defmodule AfinadosWeb.Admin.OfferLive.Index do
  @moduledoc false

  use AfinadosWeb, :live_view

  alias Afinados.Offers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, offers: Offers.list_offers(), selected: MapSet.new())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="admin">
      <Layouts.flash_group flash={@flash} />
      <h1>{gettext("Offers")}</h1>

      <.link navigate={~p"/admin/offers/new"} class="button">{gettext("New offer")}</.link>

      <div class="bulk-bar">
        <button type="button" class="link-button" phx-click="toggle-all">
          {select_all_label(@selected, @offers)}
        </button>

        <form phx-submit="apply-bulk" class="bulk-apply">
          <label class="sr-only" for="bulk-active">{gettext("New state")}</label>
          <select id="bulk-active" name="active">
            <option value="true">{gettext("Activate")}</option>
            <option value="false">{gettext("Deactivate")}</option>
          </select>
          <button type="submit">{gettext("Apply to selected")}</button>
        </form>
      </div>

      <table class="admin-table">
        <thead>
          <tr>
            <th scope="col"><span class="sr-only">{gettext("Select")}</span></th>
            <th scope="col">{gettext("Position")}</th>
            <th scope="col">{gettext("Title")}</th>
            <th scope="col">{gettext("Locale")}</th>
            <th scope="col">{gettext("Active")}</th>
            <th scope="col"><span class="sr-only">{gettext("Actions")}</span></th>
          </tr>
        </thead>
        <tbody>
          <tr :for={offer <- @offers} id={"offer-#{offer.id}"}>
            <td>
              <input
                type="checkbox"
                phx-click="toggle-row"
                phx-value-id={offer.id}
                checked={MapSet.member?(@selected, offer.id)}
                aria-label={gettext("Select %{title}", title: offer.title)}
              />
            </td>
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
  def handle_event("toggle-row", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {int_id, ""} -> {:noreply, update(socket, :selected, &toggle_member(&1, int_id))}
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle-all", _params, socket) do
    {:noreply, assign(socket, selected: next_all_selection(socket.assigns))}
  end

  @impl true
  def handle_event("apply-bulk", %{"active" => active}, socket) do
    apply_bulk(socket, MapSet.to_list(socket.assigns.selected), active == "true")
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

  defp apply_bulk(socket, [], _active) do
    {:noreply, put_flash(socket, :error, gettext("Select at least one offer"))}
  end

  defp apply_bulk(socket, ids, active) do
    count = Offers.set_offers_active(ids, active)

    {:noreply,
     socket
     |> put_flash(:info, bulk_message(active, count))
     |> assign(offers: Offers.list_offers(), selected: MapSet.new())}
  end

  defp toggle_member(selected, id) do
    case MapSet.member?(selected, id) do
      true -> MapSet.delete(selected, id)
      false -> MapSet.put(selected, id)
    end
  end

  defp next_all_selection(%{selected: selected, offers: offers}) do
    case all_selected?(selected, offers) do
      true -> MapSet.new()
      false -> MapSet.new(Enum.map(offers, & &1.id))
    end
  end

  defp all_selected?(selected, offers) do
    offers != [] and MapSet.size(selected) == length(offers)
  end

  defp select_all_label(selected, offers) do
    case all_selected?(selected, offers) do
      true -> gettext("Clear selection")
      false -> gettext("Select all")
    end
  end

  defp bulk_message(true, count) do
    ngettext("%{count} offer activated", "%{count} offers activated", count)
  end

  defp bulk_message(false, count) do
    ngettext("%{count} offer deactivated", "%{count} offers deactivated", count)
  end
end
