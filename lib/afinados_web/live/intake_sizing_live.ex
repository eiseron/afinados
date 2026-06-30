defmodule AfinadosWeb.IntakeSizingLive do
  use AfinadosWeb, :live_view

  alias Afinados.Carburetion.IntakeSizing

  alias Afinados.Carburetion.IntakeSizing.{
    Displacement,
    EngineConfig,
    RpmBand,
    VelocityPalette,
    VolumetricEfficiency
  }

  @rpm_min 2000

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
  @default_purpose "urban"
  @default_cc "125"
  @default_cylinders "1"
  @default_carbs "1"
  @default_barrels "1"
  @default_firing_interval "180"
  @default_manifold "dedicated"
  @default_induction "carburetor"
  @default_k "0.70"
  @default_boost "0"
  @default_ve "0.95"

  @impl true
  def mount(_params, _session, socket) do
    params = %{
      "vehicle" => @default_vehicle,
      "purpose" => @default_purpose,
      "cc" => @default_cc,
      "cylinders" => @default_cylinders,
      "carbs" => @default_carbs,
      "barrels" => @default_barrels,
      "firing_interval" => @default_firing_interval,
      "manifold" => @default_manifold,
      "induction" => @default_induction,
      "k" => @default_k,
      "boost" => @default_boost,
      "ve" => @default_ve
    }

    socket = assign(socket, advanced_open: false)
    {:ok, recompute(socket, params)}
  end

  @impl true
  def handle_event("change", %{"intake_sizing" => params}, socket) do
    merged = Map.merge(socket.assigns[:params] || %{}, params)
    {:noreply, recompute(socket, merged)}
  end

  def handle_event("toggle-advanced", _params, socket) do
    {:noreply, assign(socket, advanced_open: !socket.assigns.advanced_open)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <main class="intake-sizing">
      <section :if={@chart} class="chart-panel" aria-label={gettext("Efficiency zone")}>
        <svg viewBox={"0 0 #{@chart.vb_w} #{@chart.vb_h}"} width="100%" role="img" class="curve">
          <defs>
            <clipPath id="plot-clip">
              <rect
                x={@chart.x0}
                y={@chart.y_top}
                width={@chart.x1 - @chart.x0}
                height={@chart.y_bottom - @chart.y_top}
              />
            </clipPath>
            <linearGradient
              :for={cl <- @chart.commercial_lines}
              id={cl.gradient_id}
              x1={@chart.x0}
              x2={@chart.x1}
              y1={cl.y}
              y2={cl.y}
              gradientUnits="userSpaceOnUse"
            >
              <stop :for={s <- cl.gradient_stops} offset={"#{s.offset}%"} stop-color={s.color} />
            </linearGradient>
          </defs>
          <line
            :for={tick <- @chart.x_ticks}
            x1={tick.x}
            y1={@chart.y_top}
            x2={tick.x}
            y2={@chart.y_bottom}
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

          <g clip-path="url(#plot-clip)">
            <line
              :for={cl <- @chart.commercial_lines}
              x1={@chart.x0}
              y1={cl.y}
              x2={@chart.x1}
              y2={cl.y}
              class="commercial-line"
              stroke={"url(##{cl.gradient_id})"}
              stroke-width="1.2"
            />
            <line
              :for={cl <- @chart.commercial_lines}
              :if={cl.ideal_segment.visible}
              x1={cl.ideal_segment.x1}
              y1={cl.y}
              x2={cl.ideal_segment.x2}
              y2={cl.y}
              class="commercial-line-ideal"
              stroke={"url(##{cl.gradient_id})"}
              stroke-width="3"
            />
          </g>
          <text
            :for={cl <- @chart.commercial_lines}
            x={@chart.x0 - 6}
            y={cl.y + 3}
            text-anchor="end"
            class="commercial-label"
          >
            {cl.label}
          </text>
        </svg>

        <ul class="legend" aria-label={gettext("Color legend")}>
          <li :for={item <- legend_items()}>
            <svg class="swatch" width="20" height="14" viewBox="0 0 20 14" aria-hidden="true">
              <rect
                :for={{color, i} <- Enum.with_index(item.colors)}
                :if={length(item.colors) == 2}
                x={i * 11}
                width="9"
                height="14"
                rx="2"
                fill={color}
              />
              <line
                :for={{color, i} <- Enum.with_index(item.colors)}
                :if={length(item.colors) == 3}
                x1="0"
                x2="20"
                y1={3 + i * 4}
                y2={3 + i * 4}
                stroke={color}
                stroke-width="2.5"
                stroke-linecap="round"
              />
            </svg>
            {item.label}
          </li>
        </ul>
      </section>

      <p :if={!@chart} class="chart-empty">
        {gettext("Fill in the parameters to see the efficiency zone.")}
      </p>

      <h1 class="sr-only">{gettext("Intake sizing")}</h1>

      <aside class="controls" aria-label={gettext("Sizing controls")}>
        <.form for={@form} phx-change="change">
          <fieldset class="basic">
            <legend>{gettext("Parameters")}</legend>

            <.input
              field={@form[:vehicle]}
              type="select"
              label={gettext("Engine type")}
              options={vehicle_options()}
            />
            <.input
              field={@form[:purpose]}
              type="select"
              label={gettext("Application")}
              options={purpose_options(@vehicle)}
              disabled={!@purpose_selectable}
            />
            <.input
              field={@form[:induction]}
              type="select"
              label={gettext("Induction")}
              options={induction_options()}
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
              max="16"
              step="1"
            />
            <.input
              field={@form[:carbs]}
              type="number"
              label={carbs_label(@induction)}
              min="1"
              max="12"
              step="1"
            />
          </fieldset>

          <fieldset class="advanced">
            <legend>
              <button
                type="button"
                phx-click="toggle-advanced"
                aria-expanded={to_string(@advanced_open)}
              >
                {gettext("Advanced")}
              </button>
            </legend>

            <p :if={!@advanced_open} class="advanced-collapsed" aria-hidden="true">…</p>

            <div :if={@advanced_open} class="advanced-fields">
              <.input
                field={@form[:k]}
                type="select"
                label={gettext("Application profile")}
                options={k_options(@vehicle)}
              />
              <.input
                field={@form[:barrels]}
                type="select"
                label={barrels_label(@induction)}
                options={barrels_options(@induction)}
              />
              <.input
                field={@form[:manifold]}
                type="select"
                label={gettext("Intake manifold")}
                options={manifold_options()}
                disabled={!@show_manifold}
              />
              <.input
                field={@form[:firing_interval]}
                type="number"
                label={gettext("Firing interval (°)")}
                min="60"
                max="720"
                step="30"
                disabled={!@show_firing}
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
                <label for={@form[:ve].id}>{gettext("Maximum volumetric efficiency")}</label>
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
            </div>
          </fieldset>
        </.form>
      </aside>
    </main>
    """
  end

  defp recompute(socket, params) do
    vehicle = params["vehicle"] || "motorcycle"

    params =
      params
      |> normalize_k(vehicle)
      |> normalize_firing_interval()
      |> normalize_purpose(vehicle)

    purpose = params["purpose"]
    cc = parse_int(params["cc"])
    ve = parse_float(params["ve"])
    config = parse_config(params)

    chart =
      build_zone(%{cc: cc, ve: ve, config: config, vehicle: vehicle, purpose: purpose})

    assign(socket,
      params: params,
      form: to_form(params, as: :intake_sizing),
      chart: chart,
      vehicle: vehicle,
      induction: parse_induction(params["induction"]),
      ve_value: format_ve(ve),
      show_firing: show_firing?(params),
      show_manifold: show_manifold?(params),
      purpose_selectable: purpose_selectable?(vehicle)
    )
  end

  defp normalize_firing_interval(params) do
    case parse_int(params["firing_interval"]) do
      n when is_integer(n) and n >= 60 and n <= 720 -> params
      _ -> Map.put(params, "firing_interval", @default_firing_interval)
    end
  end

  defp normalize_purpose(params, vehicle) do
    if params["purpose"] in RpmBand.purposes(vehicle) do
      params
    else
      Map.put(params, "purpose", RpmBand.default_purpose(vehicle))
    end
  end

  defp purpose_selectable?(vehicle) do
    length(RpmBand.purposes(vehicle)) > 1
  end

  defp show_firing?(params) do
    cyl = parse_int(params["cylinders"]) || 1
    carbs = parse_int(params["carbs"]) || 1
    barrels = parse_int(params["barrels"]) || 1
    cyl > carbs * barrels
  end

  defp show_manifold?(params) do
    cyl = parse_int(params["cylinders"]) || 1
    carbs = parse_int(params["carbs"]) || 1
    cyl > 1 and carbs > 1
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
  defp valid_k_values("chainsaw"), do: ~w(0.73 0.77 0.82)
  defp valid_k_values("jetski"), do: ~w(0.70 0.75 0.82)
  defp valid_k_values("outboard"), do: ~w(0.62 0.66 0.72)
  defp valid_k_values("kart"), do: ~w(0.72 0.78 0.85)
  defp valid_k_values("stationary"), do: ~w(0.75)
  defp valid_k_values(_vehicle), do: ~w(0.60 0.65 0.70)

  defp default_k("motorcycle"), do: "0.70"
  defp default_k("moped"), do: "0.78"
  defp default_k("chainsaw"), do: "0.73"
  defp default_k("jetski"), do: "0.70"
  defp default_k("outboard"), do: "0.62"
  defp default_k("kart"), do: "0.72"
  defp default_k("stationary"), do: "0.75"
  defp default_k(_vehicle), do: "0.60"

  defp build_zone(%{
         cc: cc,
         ve: ve,
         config: %EngineConfig{} = config,
         vehicle: vehicle,
         purpose: purpose
       })
       when is_integer(cc) and cc > 0 and is_float(ve) do
    with {:ok, displacement} <- Displacement.new(cc),
         {:ok, vol_eff} <- VolumetricEfficiency.new(ve) do
      target_v = IntakeSizing.target_velocity(config)
      thresholds = VelocityPalette.thresholds(target_v, config.induction)

      engine = %{
        displacement: displacement,
        ve: vol_eff,
        config: config,
        vehicle: vehicle,
        purpose: purpose,
        thresholds: thresholds
      }

      build_chart(engine)
    else
      _ -> nil
    end
  end

  defp build_zone(_params), do: nil

  defp parse_config(params) do
    k = parse_float(params["k"])
    cylinders = parse_int(params["cylinders"]) || 1
    carbs = parse_int(params["carbs"])
    barrels = parse_int(params["barrels"]) || 1
    firing_interval = parse_int(params["firing_interval"])
    manifold = parse_manifold(params["manifold"])
    induction = parse_induction(params["induction"])
    boost = parse_float(params["boost"]) || 0.0

    with true <- k != nil and carbs != nil and firing_interval != nil,
         {:ok, config} <-
           EngineConfig.new(%{
             k: k,
             cylinders: cylinders,
             carbs: carbs,
             barrels: barrels,
             firing_interval: firing_interval,
             manifold: manifold,
             induction: induction,
             boost: boost
           }) do
      config
    else
      _ -> nil
    end
  end

  defp build_chart(engine) do
    rpm_max = RpmBand.chart_max(engine.vehicle)
    rpm_window = %{rpm_min: @rpm_min, rpm_max: rpm_max}

    visible =
      Enum.filter(IntakeSizing.commercial_diameters(), fn d ->
        ideal_segment_in_window?(d, rpm_window, engine)
      end)

    case visible do
      [] ->
        nil

      diameters ->
        [catalog_min | _] = catalog = IntakeSizing.commercial_diameters()
        catalog_max = List.last(catalog)
        d_min = max(catalog_min * 1.0, Enum.min(diameters) - 2.0)
        d_max = min(catalog_max * 1.0, Enum.max(diameters) + 2.0)

        scale = %{
          rpm_min: @rpm_min,
          rpm_max: rpm_max,
          d_min: d_min,
          d_max: d_max
        }

        %{
          vb_w: @vb_w,
          vb_h: @vb_h,
          x0: @x0,
          x1: @x1,
          y_top: @y_top,
          y_bottom: @y_bottom,
          commercial_lines:
            Enum.map(diameters, fn d ->
              build_line(%{diameter: d, scale: scale, engine: engine})
            end),
          x_ticks: x_ticks(scale)
        }
    end
  end

  defp ideal_segment_in_window?(diameter, scale, engine) do
    {anemic, restriction} = engine.thresholds
    rpm_at_anemic = IntakeSizing.rpm_for_velocity(diameter, anemic, engine)
    rpm_at_restriction = IntakeSizing.rpm_for_velocity(diameter, restriction, engine)
    rpm_at_anemic < scale.rpm_max and rpm_at_restriction > scale.rpm_min
  end

  defp build_line(%{diameter: d, scale: scale, engine: engine}) do
    y = round1(scale_y(d * 1.0, scale))

    %{
      diameter: d,
      y: y,
      label: "#{d}",
      gradient_id: "vel-grad-#{d}",
      gradient_stops: gradient_stops(d, {scale.rpm_min, scale.rpm_max}, engine),
      ideal_segment: ideal_segment(d, scale, engine)
    }
  end

  defp ideal_segment(diameter, scale, engine) do
    {anemic, restriction} = engine.thresholds
    rpm_at_anemic = IntakeSizing.rpm_for_velocity(diameter, anemic, engine)
    rpm_at_restriction = IntakeSizing.rpm_for_velocity(diameter, restriction, engine)

    lo = Enum.max([rpm_at_anemic, scale.rpm_min]) * 1.0
    hi = Enum.min([rpm_at_restriction, scale.rpm_max]) * 1.0

    if hi > lo do
      %{visible: true, x1: round1(scale_x(lo, scale)), x2: round1(scale_x(hi, scale))}
    else
      %{visible: false, x1: 0.0, x2: 0.0}
    end
  end

  defp gradient_stops(diameter, {rpm_lo, rpm_hi}, engine) when rpm_hi > rpm_lo do
    {anemic, restriction} = engine.thresholds
    induction = engine.config.induction
    green_floor = VelocityPalette.green_floor(engine.thresholds, induction)

    transitions =
      [
        IntakeSizing.rpm_for_velocity(diameter, anemic, engine),
        IntakeSizing.rpm_for_velocity(diameter, green_floor, engine),
        IntakeSizing.rpm_for_velocity(diameter, restriction, engine),
        elem(RpmBand.range(engine.vehicle, engine.purpose), 0),
        elem(RpmBand.range(engine.vehicle, engine.purpose), 1)
      ]
      |> Enum.filter(&(&1 > rpm_lo and &1 < rpm_hi))
      |> Enum.sort()

    samples = [rpm_lo] ++ flank_transitions(transitions) ++ [rpm_hi]

    Enum.map(samples, fn rpm ->
      velocity = IntakeSizing.gas_velocity(diameter, rpm, engine)
      in_band = rpm_in_band?(engine, rpm)

      color =
        VelocityPalette.color_for(%{
          velocity: velocity,
          in_band: in_band,
          thresholds: engine.thresholds,
          induction: induction
        })

      offset = Float.round((rpm - rpm_lo) / (rpm_hi - rpm_lo) * 100, 2)
      %{offset: offset, color: color}
    end)
  end

  defp flank_transitions(transitions) do
    epsilon = 0.5

    Enum.flat_map(transitions, fn rpm ->
      [rpm - epsilon, rpm + epsilon]
    end)
  end

  defp rpm_in_band?(engine, rpm) do
    {lo, hi} = RpmBand.range(engine.vehicle, engine.purpose)
    rpm >= lo and rpm <= hi
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

  defp vehicle_options do
    [
      {gettext("Motorcycle"), "motorcycle"},
      {gettext("Car"), "car"},
      {gettext("Kart"), "kart"},
      {gettext("Jetski"), "jetski"},
      {gettext("Outboard"), "outboard"},
      {gettext("Chainsaw"), "chainsaw"},
      {gettext("Stationary"), "stationary"},
      {gettext("Moped"), "moped"}
    ]
  end

  defp purpose_options(vehicle) do
    Enum.map(RpmBand.purposes(vehicle), fn purpose ->
      {purpose_label(purpose), purpose}
    end)
  end

  defp purpose_label("urban"), do: gettext("Urban")
  defp purpose_label("cruiser"), do: gettext("Cruiser")
  defp purpose_label("sport"), do: gettext("Sporty")
  defp purpose_label("track"), do: gettext("Track")
  defp purpose_label("off_road"), do: gettext("Off-road")
  defp purpose_label("hard_enduro"), do: gettext("Hard enduro")
  defp purpose_label("motocross"), do: gettext("Motocross")
  defp purpose_label("drag"), do: gettext("Drag")
  defp purpose_label("highway"), do: gettext("Highway")
  defp purpose_label("rally"), do: gettext("Rally")
  defp purpose_label("work"), do: gettext("Work")
  defp purpose_label("race"), do: gettext("Race")
  defp purpose_label("leisure"), do: gettext("Leisure")
  defp purpose_label("fishing"), do: gettext("Fishing")
  defp purpose_label("light"), do: gettext("Light")
  defp purpose_label("commute"), do: gettext("Commute")
  defp purpose_label("synchronous"), do: gettext("Synchronous")
  defp purpose_label(_), do: gettext("Urban")

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

  defp k_options("chainsaw") do
    [
      {gettext("Stock"), "0.73"},
      {gettext("Sport"), "0.77"},
      {gettext("Competition"), "0.82"}
    ]
  end

  defp k_options("jetski") do
    [
      {gettext("Stock"), "0.70"},
      {gettext("Sport"), "0.75"},
      {gettext("Competition"), "0.82"}
    ]
  end

  defp k_options("outboard") do
    [
      {gettext("Stock"), "0.62"},
      {gettext("Sport"), "0.66"},
      {gettext("Competition"), "0.72"}
    ]
  end

  defp k_options("kart") do
    [
      {gettext("Stock"), "0.72"},
      {gettext("Sport"), "0.78"},
      {gettext("Competition"), "0.85"}
    ]
  end

  defp k_options("stationary") do
    [{gettext("Steady state"), "0.75"}]
  end

  defp k_options(_vehicle) do
    [
      {gettext("Stock"), "0.60"},
      {gettext("Sport"), "0.65"},
      {gettext("Competition"), "0.70"}
    ]
  end

  defp legend_items do
    [
      %{
        colors: [
          VelocityPalette.sufficient_color(true),
          VelocityPalette.sufficient_color(false)
        ],
        label: gettext("Ideal")
      },
      %{
        colors: [
          VelocityPalette.fragile_color(true),
          VelocityPalette.fragile_color(false)
        ],
        label: gettext("Acceptable")
      },
      %{
        colors: [
          VelocityPalette.anemic_color(true),
          VelocityPalette.anemic_color(false)
        ],
        label: gettext("Low velocity")
      },
      %{
        colors: [
          VelocityPalette.restriction_color(true),
          VelocityPalette.restriction_color(false)
        ],
        label: gettext("Restrictive")
      },
      %{
        colors: [
          VelocityPalette.anemic_color(true),
          VelocityPalette.sufficient_color(true),
          VelocityPalette.restriction_color(true)
        ],
        label: gettext("Engine's working regime")
      },
      %{
        colors: [
          VelocityPalette.anemic_color(false),
          VelocityPalette.sufficient_color(false),
          VelocityPalette.restriction_color(false)
        ],
        label: gettext("Outside the working regime")
      }
    ]
  end

  defp carbs_label(:injection), do: gettext("Number of throttle bodies")
  defp carbs_label(_), do: gettext("Number of carburetors")

  defp barrels_label(:injection), do: gettext("Throttle plates per body")
  defp barrels_label(_), do: gettext("Barrels per carburetor")

  defp barrels_options(:injection) do
    [
      {gettext("Single"), "1"},
      {gettext("Dual"), "2"}
    ]
  end

  defp barrels_options(_) do
    [
      {gettext("Single"), "1"},
      {gettext("Dual (DCOE, IDF, 2E)"), "2"}
    ]
  end

  defp manifold_options do
    [
      {gettext("Dedicated"), "dedicated"},
      {gettext("Shared"), "shared"}
    ]
  end

  defp parse_manifold("shared"), do: :shared
  defp parse_manifold(_), do: :dedicated

  defp induction_options do
    [
      {gettext("Carburetor"), "carburetor"},
      {gettext("Injection"), "injection"}
    ]
  end

  defp parse_induction("injection"), do: :injection
  defp parse_induction(_), do: :carburetor

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
