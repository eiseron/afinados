defmodule AfinadosWeb.Admin.OfferLive.Form do
  @moduledoc false

  use AfinadosWeb, :live_view

  import AfinadosWeb.Components.OfferShelf, only: [offer_card: 1]

  alias Afinados.Media
  alias Afinados.Offers
  alias Afinados.Offers.Offer

  @impl true
  def mount(params, _session, socket) do
    socket =
      allow_upload(socket, :image,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: 5_000_000
      )

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

          <div class="offer-upload" phx-drop-target={@uploads.image.ref}>
            <label>{gettext("Or upload an image")}</label>
            <.live_file_input upload={@uploads.image} />

            <p :for={err <- upload_errors(@uploads.image)} class="offer-upload-error">
              {upload_error_message(err)}
            </p>

            <div :for={entry <- @uploads.image.entries} class="offer-upload-entry">
              <.live_img_preview entry={entry} class="offer-upload-preview" />
              <button
                type="button"
                class="link-button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label={gettext("Remove image")}
              >
                {gettext("Remove")}
              </button>
              <p :for={err <- upload_errors(@uploads.image, entry)} class="offer-upload-error">
                {upload_error_message(err)}
              </p>
            </div>
          </div>

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
    case put_uploaded_image(socket, params) do
      {:ok, params} ->
        save_offer(socket, socket.assigns.live_action, params)

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext("Could not upload the image"))}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
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

  defp put_uploaded_image(socket, params) do
    uploaded =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        {:ok, binary} = :file.read_file(path)
        key = Media.key(entry.client_name)
        {:ok, Media.put(key, binary, entry.client_type)}
      end)

    case uploaded do
      [{:ok, url} | _] -> {:ok, Map.put(params, "image_url", url)}
      [{:error, reason} | _] -> {:error, reason}
      [] -> {:ok, params}
    end
  end

  defp upload_error_message(:too_large), do: gettext("The image is too large (max 5 MB)")

  defp upload_error_message(:not_accepted),
    do: gettext("Only JPG, PNG or WebP images are allowed")

  defp upload_error_message(:too_many_files), do: gettext("Only one image is allowed")
  defp upload_error_message(_), do: gettext("Invalid image")

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
