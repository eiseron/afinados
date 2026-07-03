defmodule AfinadosWeb.Layouts do
  @moduledoc false
  use AfinadosWeb, :html

  embed_templates("layouts/*")

  def app_version, do: :afinados |> Application.spec(:vsn) |> to_string()

  def html_lang, do: AfinadosWeb.Gettext |> Gettext.get_locale() |> String.replace("_", "-")

  def current_locale, do: Gettext.get_locale(AfinadosWeb.Gettext)

  def asset_url(path), do: AfinadosWeb.Endpoint.static_url() <> path

  attr(:page, :string, default: "", doc: "documentation page path, mirroring the docs/ tree")

  attr(:label, :string,
    required: true,
    doc: "accessible label, and visible text for the inline variant"
  )

  attr(:variant, :string,
    default: "icon",
    values: ~w(icon inline),
    doc: "icon: a compact ? mark (top bar); inline: ? mark followed by the label"
  )

  def doc_link(assigns) do
    ~H"""
    <a
      class={["doc-link", "doc-link-#{@variant}"]}
      href={AfinadosWeb.Docs.url(@page)}
      target="_blank"
      rel="noopener noreferrer"
      aria-label={@label}
    >
      <span class="doc-link-mark" aria-hidden="true">?</span>
      <span :if={@variant == "inline"} class="doc-link-text">{@label}</span>
    </a>
    """
  end

  attr(:flash, :map, required: true, doc: "the map of flash messages")
  slot(:inner_block, required: true)

  def app(assigns) do
    ~H"""
    <main>
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
      </.flash>
    </div>
    """
  end
end
