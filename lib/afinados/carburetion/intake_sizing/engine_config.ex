defmodule Afinados.Carburetion.IntakeSizing.EngineConfig do
  @moduledoc "Engine configuration: gas velocity constant, carburetors, manifold, induction, fuel, and boost."

  @intake_duration_deg 240
  @manifolds [:dedicated, :shared]
  @inductions [:carburetor, :injection]
  @fuels [:gasoline, :flex, :ethanol, :methanol, :nitro, :cng]

  @enforce_keys [
    :k,
    :cylinders,
    :carbs,
    :barrels,
    :firing_interval,
    :manifold,
    :induction,
    :fuel,
    :boost
  ]
  defstruct @enforce_keys

  @type manifold :: :dedicated | :shared
  @type induction :: :carburetor | :injection
  @type fuel :: :gasoline | :flex | :ethanol | :methanol | :nitro | :cng

  @type t :: %__MODULE__{
          k: float(),
          cylinders: pos_integer(),
          carbs: pos_integer(),
          barrels: pos_integer(),
          firing_interval: pos_integer(),
          manifold: manifold(),
          induction: induction(),
          fuel: fuel(),
          boost: float()
        }

  @spec manifolds() :: [manifold()]
  def manifolds, do: @manifolds

  @spec inductions() :: [induction()]
  def inductions, do: @inductions

  @spec fuels() :: [fuel()]
  def fuels, do: @fuels

  @spec new(map()) :: {:ok, t()} | :error
  def new(params) when is_map(params) do
    if valid_params?(params), do: build(params), else: :error
  end

  def new(_params), do: :error

  @spec venturis(t()) :: pos_integer()
  def venturis(%__MODULE__{carbs: carbs, barrels: barrels}), do: carbs * barrels

  @spec fuel_factor(t()) :: float()
  def fuel_factor(%__MODULE__{fuel: :gasoline}), do: 1.0
  def fuel_factor(%__MODULE__{fuel: :flex}), do: 1.03
  def fuel_factor(%__MODULE__{fuel: :ethanol}), do: 1.05
  def fuel_factor(%__MODULE__{fuel: :methanol}), do: 1.10
  def fuel_factor(%__MODULE__{fuel: :nitro}), do: 1.30
  def fuel_factor(%__MODULE__{fuel: :cng}), do: 0.95

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
         induction: induction,
         fuel: fuel,
         boost: boost
       }) do
    valid_k?(k) and valid_count?(cylinders) and valid_count?(carbs) and
      barrels in [1, 2] and valid_interval?(firing_interval) and
      manifold in @manifolds and induction in @inductions and fuel in @fuels and
      valid_boost?(boost)
  end

  defp valid_params?(_params), do: false

  defp build(%{
         k: k,
         cylinders: cylinders,
         carbs: carbs,
         barrels: barrels,
         firing_interval: firing_interval,
         manifold: manifold,
         induction: induction,
         fuel: fuel,
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
       induction: induction,
       fuel: fuel,
       boost: boost * 1.0
     }}
  end

  defp valid_k?(k), do: is_number(k) and k > 0
  defp valid_count?(n), do: is_integer(n) and n >= 1
  defp valid_interval?(n), do: is_integer(n) and n >= 60 and n <= 720
  defp valid_boost?(b), do: is_number(b) and b > -1
end
