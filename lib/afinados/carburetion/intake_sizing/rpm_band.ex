defmodule Afinados.Carburetion.IntakeSizing.RpmBand do
  @moduledoc "Operating RPM band and chart RPM ceiling per (vehicle, purpose)."

  def range("motorcycle", "urban"), do: {3000, 7000}
  def range("motorcycle", "cruiser"), do: {2500, 5500}
  def range("motorcycle", "sport"), do: {6000, 12_000}
  def range("motorcycle", "track"), do: {9000, 14_000}
  def range("motorcycle", "off_road"), do: {4000, 9000}
  def range("motorcycle", "hard_enduro"), do: {3000, 9000}
  def range("motorcycle", "motocross"), do: {7000, 13_000}
  def range("motorcycle", "rally"), do: {4000, 10_000}
  def range("motorcycle", "drag"), do: {10_000, 14_000}
  def range("motorcycle", "work"), do: {3000, 6000}

  def range("car", "urban"), do: {1500, 4000}
  def range("car", "highway"), do: {2500, 4500}
  def range("car", "sport"), do: {3500, 6500}
  def range("car", "track"), do: {4000, 7000}
  def range("car", "drag"), do: {4500, 7000}
  def range("car", "off_road"), do: {1500, 3500}
  def range("car", "rally"), do: {3000, 6500}
  def range("car", "work"), do: {1500, 3000}

  def range("kart", "race"), do: {9000, 14_500}
  def range("kart", "off_road"), do: {7000, 12_000}
  def range("kart", "leisure"), do: {6000, 11_000}

  def range("jetski", "race"), do: {6500, 9000}
  def range("jetski", "leisure"), do: {4000, 6500}

  def range("outboard", "fishing"), do: {3000, 4500}
  def range("outboard", "sport"), do: {5000, 6500}
  def range("outboard", "work"), do: {2000, 4000}

  def range("chainsaw", "work"), do: {9000, 13_000}
  def range("chainsaw", "light"), do: {6000, 9000}

  def range("moped", "commute"), do: {3000, 7000}
  def range("moped", "sport"), do: {6000, 10_000}

  def range("stationary", _), do: {2900, 3700}

  def range(vehicle, purpose) do
    default = default_purpose(vehicle)

    if purpose == default do
      {2000, 8000}
    else
      range(vehicle, default)
    end
  end

  @spec range(String.t()) :: {pos_integer(), pos_integer()}
  def range(vehicle), do: range(vehicle, default_purpose(vehicle))

  @spec default_purpose(String.t()) :: String.t()
  def default_purpose("motorcycle"), do: "urban"
  def default_purpose("car"), do: "urban"
  def default_purpose("kart"), do: "race"
  def default_purpose("jetski"), do: "race"
  def default_purpose("outboard"), do: "sport"
  def default_purpose("chainsaw"), do: "work"
  def default_purpose("moped"), do: "commute"
  def default_purpose("stationary"), do: "synchronous"
  def default_purpose(_), do: "urban"

  @spec purposes(String.t()) :: [String.t()]
  def purposes("motorcycle"),
    do: ~w(urban cruiser sport track off_road hard_enduro motocross rally drag work)

  def purposes("car"),
    do: ~w(urban highway sport track drag off_road rally work)

  def purposes("kart"), do: ~w(race off_road leisure)
  def purposes("jetski"), do: ~w(race leisure)
  def purposes("outboard"), do: ~w(fishing sport work)
  def purposes("chainsaw"), do: ~w(work light)
  def purposes("moped"), do: ~w(commute sport)
  def purposes("stationary"), do: ~w(synchronous)
  def purposes(_), do: ~w(urban)

  @spec chart_max(String.t()) :: pos_integer()
  def chart_max("kart"), do: 17_000
  def chart_max(_), do: 14_000

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
