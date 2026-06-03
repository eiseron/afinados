defmodule Afinados.Carburetion.Comparison do
  @moduledoc "Compares two fuel maps: the signed free-area difference (B − A) per throttle position."

  alias Afinados.Carburetion.FuelMap

  @spec compute_difference(FuelMap.t(), FuelMap.t()) :: [%{position: 0..100, difference: float()}]
  def compute_difference(%FuelMap{points: points_a}, %FuelMap{points: points_b}) do
    Enum.zip_with(points_a, points_b, fn a, b ->
      %{position: a.position, difference: b.free_area - a.free_area}
    end)
  end
end
