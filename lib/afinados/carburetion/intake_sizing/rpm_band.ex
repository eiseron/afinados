defmodule Afinados.Carburetion.IntakeSizing.RpmBand do
  @moduledoc "Typical operating RPM band for each vehicle type."

  @spec range(String.t()) :: {pos_integer(), pos_integer()}
  def range("motorcycle"), do: {2500, 14_000}
  def range("moped"), do: {3000, 10_000}
  def range("tool"), do: {6000, 13_000}
  def range("stationary"), do: {2900, 3700}
  def range("car"), do: {1500, 6500}
  def range(_), do: {2000, 8000}

  @spec center(String.t()) :: float()
  def center(vehicle) do
    {lo, hi} = range(vehicle)
    (lo + hi) / 2
  end

  @spec overlaps?(String.t(), {number(), number()}) :: boolean()
  def overlaps?(vehicle, {rpm_lo, rpm_hi}) do
    {band_lo, band_hi} = range(vehicle)
    rpm_lo <= band_hi and rpm_hi >= band_lo
  end
end
