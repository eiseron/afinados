defmodule AfinadosWeb.HubLive do
  @moduledoc "Tools hub: the public entry point listing the available Afinados tools."

  use AfinadosWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <main class="hub">
      <div class="hub-inner">
        <section class="hub-intro">
          <h1>Afinados</h1>
          <p class="tagline">{gettext("Tools for carburetor tuning.")}</p>
          <p class="disclaimer">{gettext("Comparative estimate only, not jetting advice.")}</p>
        </section>

        <ul class="tools">
          <li>
            <.link href={~p"/carburetion/setups"} class="tool-card">
              <h2>{gettext("Fuel-passage area")}</h2>
              <p>
                {gettext("Estimate and compare the fuel-passage area across throttle position.")}
              </p>
            </.link>
          </li>
          <li>
            <.link href={~p"/carburetion/intake-sizing"} class="tool-card">
              <h2>{gettext("Intake sizing")}</h2>
              <p>{gettext("Estimate the ideal carburetor venturi size.")}</p>
            </.link>
          </li>
          <li>
            <div class="tool-card tool-card-soon" aria-disabled="true">
              <span class="badge">{gettext("Coming soon")}</span>
              <h2>{gettext("Two-stroke exhaust sizing")}</h2>
              <p>{gettext("Estimate the tuned exhaust geometry for a two-stroke engine.")}</p>
            </div>
          </li>
        </ul>
      </div>
    </main>
    """
  end
end
