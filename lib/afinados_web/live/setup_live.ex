defmodule AfinadosWeb.SetupLive do
  @moduledoc "Builds a carburetor setup from the catalog, renders its free-area curve (server-side SVG), and persists it to the guest's garage."

  use AfinadosWeb, :live_view

  alias Afinados.Carburetion
  alias Afinados.Carburetion.{Catalog, Clip, Comparison, FuelMap, Setup, Shim, Venturi}
  alias Afinados.Carburetion.Workbench
  alias Afinados.{Garage, Identity}

  @vb_w 360
  @vb_h 242
  @pad_left 44
  @pad_right 20
  @pad_top 22
  @pad_bottom 40
  @plot_w @vb_w - @pad_left - @pad_right
  @plot_h @vb_h - @pad_top - @pad_bottom
  @x0 @pad_left
  @x1 @pad_left + @plot_w
  @y_bottom @pad_top + @plot_h
  @y_top @pad_top
  @palette ~w(#2563eb #ea580c #16a34a #9333ea #dc2626 #0891b2)

  @impl true
  def mount(_params, session, socket) do
    catalog = %{
      needles: Catalog.list_needles(),
      needle_jets: Catalog.list_needle_jets()
    }

    socket =
      socket
      |> assign(catalog)
      |> assign(token: session["guest_token"], current_user: nil, current_garage: nil)
      |> assign(saved: [], compared: MapSet.new(), x_axis: :throttle)
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
  def handle_event("toggle_x_axis", _params, socket) do
    {:noreply, socket |> assign(x_axis: other_axis(socket.assigns.x_axis)) |> rebuild_chart()}
  end

  @impl true
  def handle_event("toggle_compare", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {setup_id, ""} ->
        {:noreply, socket |> update(:compared, &toggle(&1, setup_id)) |> rebuild_chart()}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="setup">
      <section :if={@chart} class="chart-panel" aria-label={gettext("Free-area curve")}>
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
          <line
            :for={tick <- @chart.y_ticks}
            x1={@chart.x0}
            y1={tick.y}
            x2={@chart.x1}
            y2={tick.y}
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
          <text
            x={@chart.x0}
            y={@chart.y_top - 8}
            text-anchor="start"
            font-size="9"
            fill="#6b7280"
            class="axis-unit"
          >
            mm²
          </text>
          <text
            x={@chart.x1}
            y={@chart.y_bottom + 30}
            text-anchor="end"
            font-size="9"
            fill="#6b7280"
            class="axis-unit"
          >
            {@chart.x_unit}
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

          <line
            :for={d <- @chart.difference}
            x1={d.x}
            y1={d.y_a}
            x2={d.x}
            y2={d.y_b}
            stroke={d.color}
            stroke-width="3"
            stroke-opacity="0.3"
          />
          <polyline
            :for={s <- @chart.series}
            points={s.polyline}
            fill="none"
            stroke={s.color}
            stroke-width="2"
          />
        </svg>

        <ul class="legend">
          <li :for={s <- @chart.series}>
            <svg width="12" height="12" aria-hidden="true">
              <rect width="12" height="12" fill={s.color} />
            </svg>
            {s.label}
          </li>
        </ul>
      </section>

      <p :if={!@chart}>{gettext("Pick a needle and a needle jet to see the curve.")}</p>

      <h1 class="sr-only">{gettext("Free fuel-passage area curve")}</h1>

      <aside class="controls" aria-label={gettext("Setup controls")}>
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
              type="select"
              label={gettext("Clip")}
              options={clip_options(@needles, @params["part_number"])}
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

        <button :if={@chart} type="button" phx-click="toggle_x_axis">
          {gettext("X axis")}: {axis_label(@x_axis)}
        </button>

        <button type="button" phx-click="save" disabled={is_nil(@active_map)}>
          {gettext("Save setup")}
        </button>

        <section :if={@saved != []} aria-label={gettext("Saved setups")}>
          <h2>{gettext("Saved setups")}</h2>
          <ul>
            <li :for={setup <- @saved}>
              <label>
                <input
                  type="checkbox"
                  phx-click="toggle_compare"
                  phx-value-id={setup.id}
                  checked={MapSet.member?(@compared, setup.id)}
                />
                {gettext("Compare")}
              </label>
              <button type="button" phx-click="load" phx-value-id={setup.id}>
                {setup.needle_part_number} · {gettext("clip")} {setup.clip_position} · {setup.carburetor.venturi_mm} mm
              </button>
            </li>
          </ul>
        </section>
      </aside>
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
    socket
    |> assign(params: params, form: to_form(params, as: :setup), active_map: fuel_map_for(params))
    |> rebuild_chart()
  end

  defp rebuild_chart(socket) do
    active =
      case socket.assigns.active_map do
        nil -> []
        map -> [%{label: gettext("Current"), map: map}]
      end

    assign(socket, chart: build_chart(active ++ compared_series(socket), socket.assigns.x_axis))
  end

  defp other_axis(:throttle), do: :needle
  defp other_axis(:needle), do: :throttle

  defp axis_label(:throttle), do: gettext("Throttle (%)")
  defp axis_label(:needle), do: gettext("Needle travel (mm)")

  defp compared_series(%{assigns: %{current_garage: nil}}), do: []

  defp compared_series(%{assigns: assigns}) do
    assigns.saved
    |> Enum.filter(&MapSet.member?(assigns.compared, &1.id))
    |> Enum.map(&compared_curve/1)
    |> Enum.reject(&is_nil/1)
  end

  defp compared_curve(setup) do
    case Workbench.resolve(setup) do
      {:ok, resolved} -> %{label: setup_label(setup), map: Carburetion.build_fuel_map(resolved)}
      :error -> nil
    end
  end

  defp setup_label(setup) do
    "#{setup.needle_part_number} · #{gettext("clip")} #{setup.clip_position} · #{setup.carburetor.venturi_mm} mm"
  end

  defp toggle(set, id) do
    case MapSet.member?(set, id) do
      true -> MapSet.delete(set, id)
      false -> MapSet.put(set, id)
    end
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
        clip: %Clip{position: clamp_clip(parse_int(params["clip_position"], 1), needle.num_clips)},
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

  defp clamp_clip(position, num_clips), do: position |> max(1) |> min(num_clips)

  defp build_chart([], _mode), do: nil

  defp build_chart(series, mode) do
    max_area =
      series |> Enum.flat_map(fn s -> Enum.map(s.map.points, & &1.free_area) end) |> Enum.max()

    y_max = if max_area <= 0.0, do: 1.0, else: max_area * 1.1
    {x_min, x_max} = x_range(series, mode)
    scale = %{mode: mode, x_min: x_min, x_max: x_max, y_max: y_max}

    rendered =
      series
      |> Enum.with_index()
      |> Enum.map(fn {serie, index} ->
        %{
          label: serie.label,
          color: Enum.at(@palette, rem(index, length(@palette))),
          polyline: series_polyline(serie.map, scale)
        }
      end)

    %{
      vb_w: @vb_w,
      vb_h: @vb_h,
      x0: @x0,
      x1: @x1,
      y_top: @y_top,
      y_bottom: @y_bottom,
      series: rendered,
      difference: difference_band(series, scale),
      x_ticks: x_ticks(mode, x_min, x_max),
      x_unit: x_unit(mode),
      y_ticks: y_ticks(y_max)
    }
  end

  defp x_unit(:throttle), do: "%"
  defp x_unit(:needle), do: "mm"

  defp y_ticks(y_max) do
    Enum.map(0..4, fn i ->
      value = y_max * i / 4
      %{y: round1(scale_y(value, y_max)), label: format_area(value)}
    end)
  end

  defp x_range(_series, :throttle), do: {0.0, 100.0}

  defp x_range(series, :needle) do
    {0.0, series |> Enum.map(fn s -> s.map.h_max - s.map.h0 end) |> Enum.max()}
  end

  defp point_x(point, _h0, :throttle), do: point.position
  defp point_x(point, h0, :needle), do: point.h - h0

  defp x_ticks(:throttle, x_min, x_max) do
    Enum.map([0, 25, 50, 75, 100], &%{x: round1(scale_x(&1, x_min, x_max)), label: "#{&1}"})
  end

  defp x_ticks(:needle, x_min, x_max) do
    Enum.map(0..4, fn i ->
      h = x_min + (x_max - x_min) * i / 4
      %{x: round1(scale_x(h, x_min, x_max)), label: "#{round(h)}"}
    end)
  end

  defp series_polyline(%FuelMap{points: points, h0: h0}, scale) do
    Enum.map_join(points, " ", fn point ->
      px = round1(scale_x(point_x(point, h0, scale.mode), scale.x_min, scale.x_max))
      "#{px},#{round1(scale_y(point.free_area, scale.y_max))}"
    end)
  end

  defp difference_band([%{map: map_a}, %{map: map_b}], %{mode: :throttle} = scale) do
    diffs = Comparison.compute_difference(map_a, map_b)

    Enum.zip_with([map_a.points, map_b.points, diffs], fn [a, b, d] ->
      %{
        x: round1(scale_x(a.position, scale.x_min, scale.x_max)),
        y_a: round1(scale_y(a.free_area, scale.y_max)),
        y_b: round1(scale_y(b.free_area, scale.y_max)),
        color: diff_color(d.difference >= 0.0)
      }
    end)
  end

  defp difference_band(_series, _scale), do: []

  defp diff_color(true), do: "#dc2626"
  defp diff_color(false), do: "#16a34a"

  defp scale_x(value, x_min, x_max) when x_max > x_min,
    do: @x0 + (value - x_min) / (x_max - x_min) * @plot_w

  defp scale_x(_value, _x_min, _x_max), do: @x0 * 1.0
  defp scale_y(area, y_max), do: @y_bottom - area / y_max * @plot_h
  defp round1(value), do: Float.round(value * 1.0, 1)
  defp format_area(value), do: :erlang.float_to_binary(value * 1.0, decimals: 2)

  defp clip_max(needles, part_number) do
    case Enum.find(needles, &(&1.part_number == part_number)) do
      nil -> 5
      needle -> needle.num_clips
    end
  end

  defp clip_options(needles, part_number) do
    Enum.map(1..clip_max(needles, part_number), &{to_string(&1), to_string(&1)})
  end
end
