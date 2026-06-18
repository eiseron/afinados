defmodule Afinados.Carburetion do
  @moduledoc "Pure carburetion core: builds the free fuel-passage area curve from a setup."

  alias Afinados.Carburetion.{
    FuelMap,
    HighJet,
    LowJet,
    Manufacturer,
    Needle,
    NeedleJet,
    Setup,
    Venturi
  }

  @positions 0..100

  @spec build_high_jet(String.t(), integer()) :: HighJet.t()
  def build_high_jet(manufacturer, number) when is_integer(number) and number > 0 do
    %HighJet{number: number, free_area_mm2: Manufacturer.high_jet_area(manufacturer, number)}
  end

  @spec build_low_jet(String.t(), number()) :: LowJet.t()
  def build_low_jet(manufacturer, number) when is_number(number) and number > 0 do
    %LowJet{number: number, free_area_mm2: Manufacturer.low_jet_area(manufacturer, number)}
  end

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
  def h0(%Setup{needle: needle, clip: clip, shim: shim}) do
    [straight_end | _] = needle.taper_points_mm
    straight_end + clip.position * 1.0 + shim.hundredths / 100
  end

  @spec compute_annular_area(Setup.t(), number()) :: float()
  def compute_annular_area(%Setup{needle: needle, needle_jet: needle_jet}, h) do
    diameter = diameter_at(needle, h)
    bore_area(needle_jet) - :math.pi() / 4 * diameter * diameter
  end

  @spec compute_effective_area(Setup.t(), number()) :: float()
  def compute_effective_area(%Setup{high_jet: high_jet} = setup, h) do
    series_area(compute_annular_area(setup, h), high_jet.free_area_mm2)
  end

  @spec compute_free_area(Setup.t(), number()) :: float()
  def compute_free_area(%Setup{low_jet: low_jet} = setup, h) do
    compute_effective_area(setup, h) + low_jet.free_area_mm2
  end

  @spec build_fuel_map(Setup.t()) :: FuelMap.t()
  def build_fuel_map(%Setup{venturi: %Venturi{mm: venturi_mm}} = setup) do
    base = h0(setup)
    h_max = base + venturi_mm

    points =
      Enum.map(@positions, fn position ->
        h = base + position / 100 * venturi_mm
        %{position: position, h: h, free_area: compute_free_area(setup, h)}
      end)

    %FuelMap{points: points, h0: base, h_max: h_max, unused_span: unused_span(base)}
  end

  defp series_area(annular, _high) when annular <= 0.0, do: 0.0
  defp series_area(_annular, high) when high <= 0.0, do: 0.0

  defp series_area(annular, high) do
    1.0 / :math.sqrt(1.0 / (annular * annular) + 1.0 / (high * high))
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

  defp unused_span(base) when base > 0.0, do: %{from: 0.0, to: Float.round(base, 1)}
  defp unused_span(_base), do: nil
end
