defmodule AfinadosWeb.IntakeSizingLive do
  use AfinadosWeb, :live_view

  alias Afinados.Carburetion.IntakeSizing

  alias Afinados.Carburetion.IntakeSizing.{
    Displacement,
    EfficiencyZone,
    EngineConfig,
    VolumetricEfficiency
  }

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

  @default_vehicle "motorcycle"
  @default_cc "125"
  @default_cylinders "1"
  @default_carbs "1"
  @default_k "0.70"
  @default_boost "0"
  @default_ve "0.85"

  @impl true
  def mount(_params, _session, socket) do
    params = %{
      "vehicle" => @default_vehicle,
      "cc" => @default_cc,
      "cylinders" => @default_cylinders,
      "carbs" => @default_carbs,
      "k" => @default_k,
      "boost" => @default_boost,
      "ve" => @default_ve
    }

    {:ok, recompute(socket, params)}
  end

  @impl true
  def handle_event("change", %{"intake_sizing" => params}, socket) do
    {:noreply, recompute(socket, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <main class="intake-sizing">
      <section :if={@chart} class="chart-panel" aria-label={gettext("Efficiency zone")}>
        <svg viewBox={"0 0 #{@chart.vb_w} #{@chart.vb_h}"} width="100%" role="img" class="curve">
          <line
            :for={tick <- @chart.x_ticks}
            x1={tick.x}
            y1={@chart.y_top}
            x2={tick.x}
            y2={@chart.y_bottom}
            class="grid-line"
          />
          <line
            :for={tick <- @chart.y_ticks}
            x1={@chart.x0}
            y1={tick.y}
            x2={@chart.x1}
            y2={tick.y}
            class="grid-line"
          />
          <text
            :for={tick <- @chart.x_ticks}
            x={tick.x}
            y={@chart.y_bottom + 16}
            text-anchor="middle"
            font-size="9"
          >
            {tick.label}
          </text>
          <text
            :for={tick <- @chart.y_ticks}
            x={@chart.x0 - 6}
            y={tick.y + 3}
            text-anchor="end"
            font-size="9"
          >
            {tick.label}
          </text>
          <text x={@chart.x0} y={@chart.y_top - 8} text-anchor="start" font-size="9" class="axis-unit">
            mm
          </text>
          <text
            x={@chart.x1}
            y={@chart.y_bottom + 30}
            text-anchor="end"
            font-size="9"
            class="axis-unit"
          >
            rpm
          </text>

          <line
            x1={@chart.x0}
            y1={@chart.y_top}
            x2={@chart.x0}
            y2={@chart.y_bottom}
            class="axis-line"
          />
          <line
            x1={@chart.x0}
            y1={@chart.y_bottom}
            x2={@chart.x1}
            y2={@chart.y_bottom}
            class="axis-line"
          />

          <polygon points={@chart.envelope_polygon} class="envelope" />
          <polyline points={@chart.curve_polyline} class="ve-curve" />
        </svg>

        <p class="ve-label">{@k_label} - {@ve_value}</p>
      </section>

      <p :if={!@chart} class="chart-empty">
        {gettext("Fill in the parameters to see the efficiency zone.")}
      </p>

      <h1 class="sr-only">{gettext("Intake sizing")}</h1>

      <aside class="controls" aria-label={gettext("Sizing controls")}>
        <.form for={@form} phx-change="change">
          <fieldset>
            <legend>{gettext("Parameters")}</legend>

            <.input
              field={@form[:vehicle]}
              type="select"
              label={gettext("Engine type")}
              options={vehicle_options()}
            />
            <.input
              field={@form[:cc]}
              type="number"
              label={gettext("Displacement (cm³)")}
              min="1"
              step="1"
            />
            <.input
              field={@form[:cylinders]}
              type="number"
              label={gettext("Number of cylinders")}
              min="1"
              max="12"
              step="1"
            />
            <.input
              field={@form[:carbs]}
              type="number"
              label={gettext("Number of carburetors")}
              min="1"
              max="12"
              step="1"
            />
            <.input
              field={@form[:k]}
              type="select"
              label={gettext("Application profile")}
              options={k_options(@vehicle)}
            />
            <.input
              field={@form[:boost]}
              type="number"
              label={gettext("Boost pressure (bar)")}
              min="0"
              max="3"
              step="0.1"
            />
            <div class="ve-slider">
              <label for={@form[:ve].id}>{gettext("Volumetric efficiency")}</label>
              <input
                type="range"
                id={@form[:ve].id}
                name={@form[:ve].name}
                value={@form[:ve].value}
                min={VolumetricEfficiency.ve_min()}
                max={VolumetricEfficiency.ve_max()}
                step="0.01"
              />
              <output>{@ve_value}</output>
            </div>
          </fieldset>
        </.form>
      </aside>
    </main>
    """
  end

  defp recompute(socket, params) do
    vehicle = params["vehicle"] || "motorcycle"
    params = normalize_k(params, vehicle)
    cc = parse_int(params["cc"])
    ve = parse_float(params["ve"])
    config = parse_config(params)

    chart = build_zone(cc, ve, config)

    assign(socket,
      params: params,
      form: to_form(params, as: :intake_sizing),
      chart: chart,
      vehicle: vehicle,
      k_label: k_label(config && config.k),
      ve_value: format_ve(ve)
    )
  end

  defp normalize_k(params, vehicle) do
    if params["k"] in valid_k_values(vehicle) do
      params
    else
      Map.put(params, "k", default_k(vehicle))
    end
  end

  defp valid_k_values("motorcycle"), do: ~w(0.70 0.72 0.75)
  defp valid_k_values("moped"), do: ~w(0.78 0.83 0.88)
  defp valid_k_values("tool"), do: ~w(0.73 0.77 0.82)
  defp valid_k_values(_vehicle), do: ~w(0.50 0.55 0.60)

  defp default_k("motorcycle"), do: "0.70"
  defp default_k("moped"), do: "0.78"
  defp default_k("tool"), do: "0.73"
  defp default_k(_vehicle), do: "0.50"

  defp build_zone(cc, ve, %EngineConfig{} = config)
       when is_integer(cc) and cc > 0 and is_float(ve) do
    with {:ok, displacement} <- Displacement.new(cc),
         {:ok, vol_eff} <- VolumetricEfficiency.new(ve) do
      zone = IntakeSizing.efficiency_zone(displacement, vol_eff, config)
      build_chart(zone)
    else
      _ -> nil
    end
  end

  defp build_zone(_cc, _ve, _config), do: nil

  defp parse_config(params) do
    k = parse_float(params["k"])
    carbs = parse_int(params["carbs"])
    cylinders = parse_int(params["cylinders"])
    boost = parse_float(params["boost"]) || 0.0

    with true <- k != nil and carbs != nil and cylinders != nil,
         {:ok, config} <-
           EngineConfig.new(%{k: k, carbs: carbs, cylinders: cylinders, boost: boost}) do
      config
    else
      _ -> nil
    end
  end

  defp build_chart(%EfficiencyZone{envelope: envelope, curve: curve}) do
    all_diameters =
      Enum.map(envelope.lower, & &1.diameter) ++
        Enum.map(envelope.upper, & &1.diameter)

    d_max = Enum.max(all_diameters) * 1.1
    d_min = max(0.0, Enum.min(all_diameters) * 0.9)
    {rpm_min, rpm_max} = rpm_range(envelope.lower)

    scale = %{rpm_min: rpm_min, rpm_max: rpm_max, d_min: d_min, d_max: d_max}

    %{
      vb_w: @vb_w,
      vb_h: @vb_h,
      x0: @x0,
      x1: @x1,
      y_top: @y_top,
      y_bottom: @y_bottom,
      envelope_polygon: envelope_polygon(envelope, scale),
      curve_polyline: points_polyline(curve, scale),
      x_ticks: x_ticks(scale),
      y_ticks: y_ticks(scale)
    }
  end

  defp rpm_range(points) do
    rpms = Enum.map(points, & &1.rpm)
    {Enum.min(rpms), Enum.max(rpms)}
  end

  defp envelope_polygon(%{lower: lower, upper: upper}, scale) do
    upper_line = Enum.map_join(upper, " ", &point_str(&1, scale))
    lower_line = lower |> Enum.reverse() |> Enum.map_join(" ", &point_str(&1, scale))
    upper_line <> " " <> lower_line
  end

  defp points_polyline(points, scale) do
    Enum.map_join(points, " ", &point_str(&1, scale))
  end

  defp point_str(%{rpm: rpm, diameter: d}, scale) do
    "#{round1(scale_x(rpm, scale))},#{round1(scale_y(d, scale))}"
  end

  defp scale_x(rpm, %{rpm_min: rpm_min, rpm_max: rpm_max}) when rpm_max > rpm_min do
    @x0 + (rpm - rpm_min) / (rpm_max - rpm_min) * @plot_w
  end

  defp scale_x(_rpm, _scale), do: @x0 * 1.0

  defp scale_y(diameter, %{d_min: d_min, d_max: d_max}) when d_max > d_min do
    @y_bottom - (diameter - d_min) / (d_max - d_min) * @plot_h
  end

  defp scale_y(_diameter, _scale), do: @y_bottom * 1.0

  defp x_ticks(%{rpm_min: rpm_min, rpm_max: rpm_max} = scale) do
    step = tick_step(rpm_max - rpm_min, 5)
    first = Float.ceil(rpm_min / step) * step

    first
    |> Stream.iterate(&(&1 + step))
    |> Enum.take_while(&(&1 <= rpm_max))
    |> Enum.map(&%{x: round1(scale_x(&1, scale)), label: "#{round(&1)}"})
  end

  defp y_ticks(%{d_min: d_min, d_max: d_max} = scale) do
    step = tick_step(d_max - d_min, 5)
    first = Float.ceil(d_min / step) * step

    first
    |> Stream.iterate(&(&1 + step))
    |> Enum.take_while(&(&1 <= d_max))
    |> Enum.map(&%{y: round1(scale_y(&1, scale)), label: format_diameter(&1)})
  end

  defp tick_step(range, target_count) when range > 0 do
    raw = range / target_count
    magnitude = :math.pow(10, Float.floor(:math.log10(raw)))

    normalized = raw / magnitude

    multiplier =
      cond do
        normalized < 1.5 -> 1
        normalized < 3.5 -> 2
        normalized < 7.5 -> 5
        true -> 10
      end

    multiplier * magnitude
  end

  defp tick_step(_range, _target), do: 1.0

  defp round1(value), do: Float.round(value * 1.0, 1)
  defp format_diameter(value), do: :erlang.float_to_binary(value * 1.0, decimals: 1)

  defp vehicle_options do
    [
      {gettext("Motorcycle"), "motorcycle"},
      {gettext("Car"), "car"},
      {gettext("Power tool"), "tool"},
      {gettext("Moped"), "moped"}
    ]
  end

  defp k_options("motorcycle") do
    [
      {gettext("Stock"), "0.70"},
      {gettext("Sport"), "0.72"},
      {gettext("Competition"), "0.75"}
    ]
  end

  defp k_options("moped") do
    [
      {gettext("Stock"), "0.78"},
      {gettext("Sport"), "0.83"},
      {gettext("Competition"), "0.88"}
    ]
  end

  defp k_options("tool") do
    [
      {gettext("Stock"), "0.73"},
      {gettext("Sport"), "0.77"},
      {gettext("Competition"), "0.82"}
    ]
  end

  defp k_options(_vehicle) do
    [
      {gettext("Stock"), "0.50"},
      {gettext("Sport"), "0.55"},
      {gettext("Competition"), "0.60"}
    ]
  end

  defp k_label(0.5), do: gettext("Stock")
  defp k_label(0.55), do: gettext("Sport")
  defp k_label(0.6), do: gettext("Competition")
  defp k_label(0.78), do: gettext("Stock")
  defp k_label(0.83), do: gettext("Sport")
  defp k_label(0.88), do: gettext("Competition")
  defp k_label(0.73), do: gettext("Stock")
  defp k_label(0.77), do: gettext("Sport")
  defp k_label(0.82), do: gettext("Competition")
  defp k_label(0.7), do: gettext("Stock")
  defp k_label(0.72), do: gettext("Sport")
  defp k_label(0.75), do: gettext("Competition")
  defp k_label(_k), do: ""

  defp parse_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {i, _} when i > 0 -> i
      _ -> nil
    end
  end

  defp parse_int(value) when is_integer(value) and value > 0, do: value
  defp parse_int(_value), do: nil

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {f, _} -> f
      :error -> nil
    end
  end

  defp parse_float(value) when is_number(value), do: value * 1.0
  defp parse_float(_value), do: nil

  defp format_ve(nil), do: ""
  defp format_ve(ve), do: "#{round(ve * 100)}%"
end
