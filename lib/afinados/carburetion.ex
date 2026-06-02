defmodule Afinados.Carburetion do
  @moduledoc "Pure carburetion core: builds the free fuel-passage area curve from a setup."

  alias Afinados.Carburetion.{FuelMap, Needle, NeedleJet, Setup, Venturi}

  @positions 0..100

  @spec diameter_at(Needle.t(), number()) :: float()
  def diameter_at(%Needle{station_diameters_mm: [d0 | _] = diameters} = needle, position_mm)
      when is_number(position_mm) do
    [straight_end | _] = needle.taper_points_mm

    cond do
      position_mm <= straight_end -> d0
      position_mm >= needle.total_length_mm -> List.last(diameters)
      true -> interpolate_taper(diameters, {straight_end, needle.total_length_mm}, position_mm)
    end
  end

  @spec bore_area(NeedleJet.t()) :: float()
  def bore_area(%NeedleJet{bore_mm: bore_mm}), do: :math.pi() / 4 * bore_mm * bore_mm

  @spec h0(Setup.t()) :: float()
  def h0(%Setup{clip: clip, shim: shim}), do: clip.position * 1.0 + shim.hundredths / 100

  @spec compute_annular_area(Setup.t(), number()) :: float()
  def compute_annular_area(%Setup{needle: needle, needle_jet: needle_jet}, h) do
    diameter = diameter_at(needle, h)
    bore_area(needle_jet) - :math.pi() / 4 * diameter * diameter
  end

  @spec build_fuel_map(Setup.t()) :: FuelMap.t()
  def build_fuel_map(%Setup{venturi: %Venturi{mm: venturi_mm}, needle: needle} = setup) do
    base = h0(setup)
    h_max = base + venturi_mm

    points =
      Enum.map(@positions, fn position ->
        h = base + position / 100 * venturi_mm
        %{position: position, h: h, free_area: compute_annular_area(setup, h)}
      end)

    %FuelMap{points: points, h0: base, h_max: h_max, unused_span: unused_span(needle, h_max)}
  end

  defp interpolate_taper(diameters, {straight_end, total_length_mm}, position_mm) do
    stations = length(diameters)
    step = (total_length_mm - straight_end) / (stations - 1)
    index = (position_mm - straight_end) / step
    lower = trunc(index)
    fraction = index - lower
    d_low = Enum.at(diameters, lower)
    d_high = Enum.at(diameters, min(lower + 1, stations - 1))
    d_low + fraction * (d_high - d_low)
  end

  defp unused_span(%Needle{total_length_mm: total_length_mm}, h_max) when total_length_mm > h_max,
    do: %{from: h_max, to: total_length_mm}

  defp unused_span(_needle, _h_max), do: nil
end
