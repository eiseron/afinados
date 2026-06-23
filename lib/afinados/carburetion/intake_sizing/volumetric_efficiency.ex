defmodule Afinados.Carburetion.IntakeSizing.VolumetricEfficiency do
  @moduledoc "Volumetric efficiency envelope. The user sets the maximum; the minimum is derived."

  @enforce_keys [:value]
  @ve_min 0.5
  @ve_max 1.15
  @envelope_width 0.30

  defstruct @enforce_keys

  @type t :: %__MODULE__{value: float()}

  def ve_min, do: @ve_min
  def ve_max, do: @ve_max
  def envelope_width, do: @envelope_width

  @spec new(number()) :: {:ok, t()} | :error
  def new(value) when is_number(value) and value >= @ve_min and value <= @ve_max do
    {:ok, %__MODULE__{value: value * 1.0}}
  end

  def new(_value), do: :error

  @spec envelope_max(t()) :: float()
  def envelope_max(%__MODULE__{value: value}), do: value

  @spec envelope_min(t()) :: float()
  def envelope_min(%__MODULE__{value: value}), do: value - @envelope_width
end
