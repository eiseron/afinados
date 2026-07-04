defmodule AfinadosWeb.Admin.HomeLive do
  @moduledoc "Admin landing page, gated by Cloudflare Access. Offer management lands here in a later slice."

  use AfinadosWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <main class="admin">
      <h1>{gettext("Admin")}</h1>
      <nav>
        <.link navigate={~p"/admin/offers"}>{gettext("Offers")}</.link>
      </nav>
    </main>
    """
  end
end
