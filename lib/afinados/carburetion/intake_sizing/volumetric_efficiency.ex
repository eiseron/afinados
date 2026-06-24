defmodule Afinados.Carburetion.IntakeSizing.VolumetricEfficiency do
  @moduledoc "Peak volumetric efficiency. Single value, used directly in gas-velocity computation."

  @enforce_keys [:value]
  @ve_min 0.5
  @ve_max 1.15

  defstruct @enforce_keys

  @type t :: %__MODULE__{value: float()}

  def ve_min, do: @ve_min
  def ve_max, do: @ve_max

  @spec new(number()) :: {:ok, t()} | :error
  def new(value) when is_number(value) and value >= @ve_min and value <= @ve_max do
    {:ok, %__MODULE__{value: value * 1.0}}
  end

  def new(_value), do: :error
end
