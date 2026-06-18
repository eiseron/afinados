defmodule Afinados.Carburetion.Manufacturer do
  @moduledoc "Per-manufacturer jet parametrisation: resolves a jet number to its free area (mm²). Native catalog/UI units normalise here, at the edge, so the core stays manufacturer-agnostic."

  @manufacturers [
    {"mikuni", %{pilot_area_per_number: 0.005}}
  ]

  @params Map.new(@manufacturers)
  @default "mikuni"

  @spec default() :: String.t()
  def default, do: @default

  @spec all() :: [String.t()]
  def all, do: Enum.map(@manufacturers, &elem(&1, 0))

  @spec known?(String.t()) :: boolean()
  def known?(manufacturer), do: Map.has_key?(@params, manufacturer)

  @spec high_jet_area(String.t(), number()) :: float()
  def high_jet_area(_manufacturer, number) do
    diameter_mm = number / 100
    :math.pi() / 4 * diameter_mm * diameter_mm
  end

  @spec low_jet_area(String.t(), number()) :: float()
  def low_jet_area(manufacturer, number) do
    params(manufacturer).pilot_area_per_number * number
  end

  defp params(manufacturer), do: Map.get(@params, manufacturer, @params[@default])
end
