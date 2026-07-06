defmodule AfinadosWeb.Admin.OfferLive.Form do
  @moduledoc false

  use AfinadosWeb, :live_view

  import AfinadosWeb.Components.OfferShelf, only: [offer_card: 1]

  alias Afinados.Offers
  alias Afinados.Offers.Offer

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="admin">
      <Layouts.flash_group flash={@flash} />
      <h1>{@page_title}</h1>

      <div class="offer-editor">
        <section class="offer-preview" aria-label={gettext("Card preview")}>
          <h2 class="offer-preview-title">{gettext("Preview")}</h2>
          <div class="offer-preview-card">
            <.offer_card offer={@preview} />
          </div>
        </section>

        <.form for={@form} id="offer-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} label={gettext("Title")} />
          <.input
            field={@form[:locale]}
            type="select"
            label={gettext("Locale")}
            options={AfinadosWeb.Locale.locales()}
          />
          <.input field={@form[:description]} type="textarea" label={gettext("Description")} />
          <.input field={@form[:target_url]} label={gettext("Target URL")} />
          <.input field={@form[:image_url]} label={gettext("Image URL")} />
          <.input
            field={@form[:surfaces]}
            type="select"
            multiple
            label={gettext("Where it shows")}
            options={surface_options()}
          />
          <.input field={@form[:position]} type="number" label={gettext("Position")} />
          <.input field={@form[:active]} type="checkbox" label={gettext("Active")} />

          <button type="submit">{gettext("Save")}</button>
        </.form>
      </div>

      <.link navigate={~p"/admin/offers"}>{gettext("Back to offers")}</.link>
    </main>
    """
  end

  @impl true
  def handle_event("validate", %{"offer" => params}, socket) do
    changeset = Offers.change_offer(socket.assigns.offer, params)

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  @impl true
  def handle_event("save", %{"offer" => params}, socket) do
    save_offer(socket, socket.assigns.live_action, params)
  end

  defp apply_action(socket, :new, _params) do
    offer = %Offer{}

    socket
    |> assign(page_title: gettext("New offer"), offer: offer)
    |> assign_form(Offers.change_offer(offer))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    with {int_id, ""} <- Integer.parse(id),
         %Offers.Offer{} = offer <- Offers.get_offer(int_id) do
      socket
      |> assign(page_title: gettext("Edit offer"), offer: offer)
      |> assign_form(Offers.change_offer(offer))
    else
      _ ->
        socket
        |> put_flash(:error, gettext("Offer not found"))
        |> push_navigate(to: ~p"/admin/offers")
    end
  end

  defp save_offer(socket, :new, params) do
    case Offers.create_offer(params) do
      {:ok, _offer} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Offer created"))
         |> push_navigate(to: ~p"/admin/offers")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_offer(socket, :edit, params) do
    case Offers.update_offer(socket.assigns.offer, params) do
      {:ok, _offer} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Offer updated"))
         |> push_navigate(to: ~p"/admin/offers")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket
    |> assign(form: to_form(changeset, as: :offer))
    |> assign(preview: Ecto.Changeset.apply_changes(changeset))
  end

  defp surface_labels do
    %{"hub_shelf" => gettext("Hub shelf")}
  end

  defp surface_options do
    Offer.surfaces() |> Enum.map(fn s -> {Map.get(surface_labels(), s, s), s} end)
  end
end
