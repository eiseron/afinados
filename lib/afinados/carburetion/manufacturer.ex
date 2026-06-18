defmodule Afinados.Carburetion.Manufacturer do
  @moduledoc "Per-manufacturer jet parametrisation: resolves a jet number to its free area (mm²). Native catalog/UI units normalise here, at the edge, so the core stays manufacturer-agnostic. The main jet is the same diameter model for both manufacturers (modern round-head Mikuni and Keihin both publish the main as the orifice diameter in 1/100 mm). The pilot jet is geometric for Keihin (numbered in 1/100 mm orifice diameter, same shape as the main) and a placeholder for Mikuni (proprietary flow numbering; calibration tracked in afinados-planning#7)."

  @manufacturers [
    {"mikuni", %{pilot_model: {:flow_placeholder, 0.005}}},
    {"keihin", %{pilot_model: :diameter}}
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
  def high_jet_area(_manufacturer, number), do: diameter_to_area(number)

  @spec low_jet_area(String.t(), number()) :: float()
  def low_jet_area(manufacturer, number) do
    pilot_area(params(manufacturer).pilot_model, number)
  end

  defp pilot_area(:diameter, number), do: diameter_to_area(number)
  defp pilot_area({:flow_placeholder, k}, number), do: k * number

  defp diameter_to_area(number) do
    diameter_mm = number / 100
    :math.pi() / 4 * diameter_mm * diameter_mm
  end

  defp params(manufacturer), do: Map.get(@params, manufacturer, @params[@default])
end
