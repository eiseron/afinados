defmodule AfinadosWeb.SetupLive do
  @moduledoc "Builds a carburetor setup from the catalog, renders its free-area curve (server-side SVG), and persists it to the guest's garage."

  use AfinadosWeb, :live_view

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Catalog, Clip, FuelMap, Setup, Shim, Venturi}
  alias Afinados.Carburetion.Workbench
  alias Afinados.{Garage, Identity}

  @vb_w 360
  @vb_h 220
  @pad_left 44
  @pad_right 12
  @pad_top 12
  @pad_bottom 28
  @plot_w @vb_w - @pad_left - @pad_right
  @plot_h @vb_h - @pad_top - @pad_bottom
  @x0 @pad_left
  @x1 @pad_left + @plot_w
  @y_bottom @pad_top + @plot_h
  @y_top @pad_top

  @impl true
  def mount(_params, session, socket) do
    catalog = %{
      needles: Catalog.list_needles(),
      needle_jets: Catalog.list_needle_jets()
    }

    socket =
      socket
      |> assign(catalog)
      |> assign(token: session["guest_token"], current_user: nil, current_garage: nil, saved: [])
      |> load_work(Identity.user_for_token(session["guest_token"]))
      |> recompute(default_params(catalog))

    {:ok, socket}
  end

  @impl true
  def handle_event("change", %{"setup" => params}, socket) do
    {:noreply, recompute(socket, params)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    user = Identity.ensure_user_for_token(socket.assigns.token)
    garage = Garage.default_for(user)

    case Workbench.save_setup(garage, socket.assigns.params) do
      {:ok, _setup} -> {:noreply, load_work(socket, user)}
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("load", %{"id" => id}, socket) do
    with %Garage{} = garage <- socket.assigns.current_garage,
         {setup_id, ""} <- Integer.parse(id),
         setup when not is_nil(setup) <- Workbench.get_setup(garage, setup_id) do
      {:noreply, recompute(socket, saved_params(setup))}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="setup">
      <h1>{gettext("Free fuel-passage area curve")}</h1>

      <.form for={@form} phx-change="change">
        <fieldset>
          <legend>{gettext("Setup")}</legend>

          <.input
            field={@form[:part_number]}
            type="select"
            label={gettext("Needle")}
            options={Enum.map(@needles, &{&1.part_number, &1.part_number})}
          />
          <.input
            field={@form[:needle_jet_code]}
            type="select"
            label={gettext("Needle jet")}
            options={Enum.map(@needle_jets, &{&1.code, &1.code})}
          />
          <.input
            field={@form[:high_jet_number]}
            type="number"
            label={gettext("Main jet")}
            min="1"
            step="1"
          />
          <.input
            field={@form[:low_jet_number]}
            type="number"
            label={gettext("Pilot jet")}
            min="1"
            step="0.5"
          />
          <.input
            field={@form[:clip_position]}
            type="number"
            label={gettext("Clip")}
            min="1"
            max={clip_max(@needles, @params["part_number"])}
          />
          <.input
            field={@form[:shim_hundredths]}
            type="number"
            label={gettext("Shim (hundredths of mm)")}
            min="0"
          />
          <.input field={@form[:venturi_mm]} type="number" label={gettext("Venturi (mm)")} min="1" />
        </fieldset>
      </.form>

      <button type="button" phx-click="save" disabled={is_nil(@chart)}>
        {gettext("Save setup")}
      </button>

      <section :if={@chart} aria-label={gettext("Free-area curve")}>
        <p>
          {gettext("Maximum free area")}:
          <strong id="max-area">{format_area(@chart.max_area)}</strong>
          mm²
        </p>

        <svg viewBox={"0 0 #{@chart.vb_w} #{@chart.vb_h}"} width="100%" role="img" class="curve">
          <line
            :for={tick <- @chart.x_ticks}
            x1={tick.x}
            y1={@chart.y_top}
            x2={tick.x}
            y2={@chart.y_bottom}
            stroke="#e5e7eb"
            stroke-width="1"
          />
          <text
            :for={tick <- @chart.x_ticks}
            x={tick.x}
            y={@chart.y_bottom + 16}
            text-anchor="middle"
            font-size="9"
            fill="#6b7280"
          >
            {tick.label}
          </text>
          <text
            :for={tick <- @chart.y_ticks}
            x={@chart.x0 - 6}
            y={tick.y + 3}
            text-anchor="end"
            font-size="9"
            fill="#6b7280"
          >
            {tick.label}
          </text>

          <line
            x1={@chart.x0}
            y1={@chart.y_top}
            x2={@chart.x0}
            y2={@chart.y_bottom}
            stroke="#9ca3af"
            stroke-width="1"
          />
          <line
            x1={@chart.x0}
            y1={@chart.y_bottom}
            x2={@chart.x1}
            y2={@chart.y_bottom}
            stroke="#9ca3af"
            stroke-width="1"
          />

          <polyline points={@chart.polyline} fill="none" stroke="#2563eb" stroke-width="2" />
        </svg>
      </section>

      <p :if={!@chart}>{gettext("Pick a needle and a needle jet to see the curve.")}</p>

      <section :if={@saved != []} aria-label={gettext("Saved setups")}>
        <h2>{gettext("Saved setups")}</h2>
        <ul>
          <li :for={setup <- @saved}>
            <button type="button" phx-click="load" phx-value-id={setup.id}>
              {setup.needle_part_number} · {gettext("clip")} {setup.clip_position} · {setup.carburetor.venturi_mm} mm
            </button>
          </li>
        </ul>
      </section>
    </main>
    """
  end

  defp load_work(socket, nil),
    do: assign(socket, current_user: nil, current_garage: nil, saved: [])

  defp load_work(socket, user) do
    case Garage.list_for(user) do
      [garage | _] ->
        assign(socket,
          current_user: user,
          current_garage: garage,
          saved: Workbench.list_setups(garage)
        )

      [] ->
        assign(socket, current_user: user, current_garage: nil, saved: [])
    end
  end

  defp default_params(%{needles: []}), do: %{}

  defp default_params(catalog) do
    %{
      "part_number" => hd(catalog.needles).part_number,
      "needle_jet_code" => first_field(catalog.needle_jets, :code),
      "high_jet_number" => "150",
      "low_jet_number" => "25",
      "clip_position" => "3",
      "shim_hundredths" => "0",
      "venturi_mm" => "34"
    }
  end

  defp first_field([], _key), do: ""
  defp first_field([record | _], key), do: Map.fetch!(record, key)

  defp saved_params(setup) do
    %{
      "part_number" => setup.needle_part_number,
      "needle_jet_code" => setup.needle_jet_code,
      "high_jet_number" => to_string(setup.high_jet_number),
      "low_jet_number" => to_string(setup.low_jet_number),
      "clip_position" => to_string(setup.clip_position),
      "shim_hundredths" => to_string(setup.shim_hundredths),
      "venturi_mm" => to_string(setup.carburetor.venturi_mm)
    }
  end

  defp recompute(socket, params) do
    fuel_map = fuel_map_for(params)

    socket
    |> assign(params: params, form: to_form(params, as: :setup))
    |> assign(fuel_map: fuel_map, chart: fuel_map && build_chart(fuel_map))
  end

  defp fuel_map_for(params) do
    with {:ok, needle} <- Catalog.fetch_needle(params["part_number"]),
         {:ok, needle_jet} <- Catalog.fetch_needle_jet(params["needle_jet_code"]),
         {high_number, ""} when high_number > 0 <-
           Integer.parse(to_string(params["high_jet_number"])),
         {low_number, ""} when low_number > 0 <-
           Float.parse(to_string(params["low_jet_number"])) do
      %Setup{
        needle: needle,
        needle_jet: needle_jet,
        high_jet: Carburetion.build_high_jet(high_number),
        low_jet: Carburetion.build_low_jet(low_number),
        clip: %Clip{position: parse_int(params["clip_position"], 1)},
        shim: %Shim{hundredths: parse_int(params["shim_hundredths"], 0)},
        venturi: %Venturi{mm: parse_int(params["venturi_mm"], 1) * 1.0}
      }
      |> Carburetion.build_fuel_map()
    else
      _ -> nil
    end
  end

  defp parse_int(value, default) do
    case Integer.parse(to_string(value)) do
      {int, _rest} when int >= 0 -> int
      _ -> default
    end
  end

  defp build_chart(%FuelMap{points: points}) do
    areas = Enum.map(points, & &1.free_area)
    max_area = Enum.max(areas)
    y_max = if max_area <= 0.0, do: 1.0, else: max_area * 1.1

    polyline =
      Enum.map_join(points, " ", fn point ->
        "#{round1(scale_x(point.position))},#{round1(scale_y(point.free_area, y_max))}"
      end)

    %{
      vb_w: @vb_w,
      vb_h: @vb_h,
      x0: @x0,
      x1: @x1,
      y_top: @y_top,
      y_bottom: @y_bottom,
      polyline: polyline,
      max_area: max_area,
      x_ticks: Enum.map([0, 25, 50, 75, 100], &%{x: round1(scale_x(&1)), label: "#{&1}%"}),
      y_ticks: [%{y: @y_bottom, label: "0"}, %{y: @y_top, label: format_area(y_max)}]
    }
  end

  defp scale_x(position), do: @x0 + position / 100 * @plot_w
  defp scale_y(area, y_max), do: @y_bottom - area / y_max * @plot_h
  defp round1(value), do: Float.round(value * 1.0, 1)
  defp format_area(value), do: :erlang.float_to_binary(value * 1.0, decimals: 2)

  defp clip_max(needles, part_number) do
    case Enum.find(needles, &(&1.part_number == part_number)) do
      nil -> 5
      needle -> needle.num_clips
    end
  end
end
