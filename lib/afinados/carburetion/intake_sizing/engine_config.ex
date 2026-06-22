defmodule Afinados.Carburetion.IntakeSizing.EngineConfig do
  @moduledoc "Engine configuration: gas velocity constant, carburetors, and boost."

  @intake_duration_deg 240

  @enforce_keys [:k, :cylinders, :carbs, :barrels, :firing_interval, :boost]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          k: float(),
          cylinders: pos_integer(),
          carbs: pos_integer(),
          barrels: pos_integer(),
          firing_interval: pos_integer(),
          boost: float()
        }

  @spec new(map()) :: {:ok, t()} | :error
  def new(params) when is_map(params) do
    if valid_params?(params), do: build(params), else: :error
  end

  def new(_params), do: :error

  @spec venturis(t()) :: pos_integer()
  def venturis(%__MODULE__{carbs: carbs, barrels: barrels}), do: carbs * barrels

  @spec pulse_divisor(t()) :: float()
  def pulse_divisor(%__MODULE__{cylinders: cyl, firing_interval: interval} = config) do
    v = venturis(config)
    per_venturi_interval = interval * v
    concurrent = max(1.0, @intake_duration_deg / per_venturi_interval)
    max(v * 1.0, cyl / concurrent)
  end

  @spec p_abs(t()) :: float()
  def p_abs(%__MODULE__{boost: boost}), do: 1.0 + boost

  defp valid_params?(%{
         k: k,
         cylinders: cylinders,
         carbs: carbs,
         barrels: barrels,
         firing_interval: firing_interval,
         boost: boost
       }) do
    valid_k?(k) and valid_count?(cylinders) and valid_count?(carbs) and
      barrels in [1, 2] and valid_interval?(firing_interval) and valid_boost?(boost)
  end

  defp valid_params?(_params), do: false

  defp build(%{
         k: k,
         cylinders: cylinders,
         carbs: carbs,
         barrels: barrels,
         firing_interval: firing_interval,
         boost: boost
       }) do
    {:ok,
     %__MODULE__{
       k: k,
       cylinders: cylinders,
       carbs: carbs,
       barrels: barrels,
       firing_interval: firing_interval,
       boost: boost * 1.0
     }}
  end

  defp valid_k?(k), do: is_number(k) and k > 0
  defp valid_count?(n), do: is_integer(n) and n >= 1
  defp valid_interval?(n), do: is_integer(n) and n >= 60 and n <= 720
  defp valid_boost?(b), do: is_number(b) and b > -1
end
