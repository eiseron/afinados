defmodule Afinados.Carburetion.IntakeSizing.EngineConfig do
  @moduledoc "Engine configuration: gas velocity constant, carburetors, manifold topology, and boost."

  @intake_duration_deg 240
  @manifolds [:dedicated, :shared]

  @enforce_keys [:k, :cylinders, :carbs, :barrels, :firing_interval, :manifold, :boost]
  defstruct @enforce_keys

  @type manifold :: :dedicated | :shared

  @type t :: %__MODULE__{
          k: float(),
          cylinders: pos_integer(),
          carbs: pos_integer(),
          barrels: pos_integer(),
          firing_interval: pos_integer(),
          manifold: manifold(),
          boost: float()
        }

  @spec manifolds() :: [manifold()]
  def manifolds, do: @manifolds

  @spec new(map()) :: {:ok, t()} | :error
  def new(params) when is_map(params) do
    if valid_params?(params), do: build(params), else: :error
  end

  def new(_params), do: :error

  @spec venturis(t()) :: pos_integer()
  def venturis(%__MODULE__{carbs: carbs, barrels: barrels}), do: carbs * barrels

  @spec pulse_divisor(t()) :: float()
  def pulse_divisor(
        %__MODULE__{cylinders: cyl, firing_interval: interval, manifold: manifold} = config
      ) do
    v = venturis(config)

    case manifold do
      :dedicated ->
        per_venturi_interval = interval * v
        concurrent = max(1.0, @intake_duration_deg / per_venturi_interval)
        max(v * 1.0, cyl / concurrent)

      :shared ->
        engine_concurrent = max(1.0, @intake_duration_deg / interval)
        max(v * 1.0, cyl * v / engine_concurrent)
    end
  end

  @spec p_abs(t()) :: float()
  def p_abs(%__MODULE__{boost: boost}), do: 1.0 + boost

  defp valid_params?(%{
         k: k,
         cylinders: cylinders,
         carbs: carbs,
         barrels: barrels,
         firing_interval: firing_interval,
         manifold: manifold,
         boost: boost
       }) do
    valid_k?(k) and valid_count?(cylinders) and valid_count?(carbs) and
      barrels in [1, 2] and valid_interval?(firing_interval) and
      manifold in @manifolds and valid_boost?(boost)
  end

  defp valid_params?(_params), do: false

  defp build(%{
         k: k,
         cylinders: cylinders,
         carbs: carbs,
         barrels: barrels,
         firing_interval: firing_interval,
         manifold: manifold,
         boost: boost
       }) do
    {:ok,
     %__MODULE__{
       k: k,
       cylinders: cylinders,
       carbs: carbs,
       barrels: barrels,
       firing_interval: firing_interval,
       manifold: manifold,
       boost: boost * 1.0
     }}
  end

  defp valid_k?(k), do: is_number(k) and k > 0
  defp valid_count?(n), do: is_integer(n) and n >= 1
  defp valid_interval?(n), do: is_integer(n) and n >= 60 and n <= 720
  defp valid_boost?(b), do: is_number(b) and b > -1
end
