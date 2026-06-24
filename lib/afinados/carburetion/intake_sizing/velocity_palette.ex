defmodule Afinados.Carburetion.IntakeSizing.VelocityPalette do
  @moduledoc """
  Picks a solid color for a commercial venturi line from three signals:

    - whether the line's RPM sits inside the engine's working band
    - whether the gas velocity at that RPM exceeds the restriction threshold
    - whether the gas velocity falls below the anemic threshold

  Thresholds are dynamic: they slide with the engine's target velocity (derived from K
  in `IntakeSizing.target_velocity/1`).
  """

  @band_half_width 30.0

  @spec band_half_width() :: float()
  def band_half_width, do: @band_half_width

  @spec thresholds(number()) :: {float(), float()}
  def thresholds(target_velocity) when is_number(target_velocity) and target_velocity > 0 do
    {target_velocity - @band_half_width, target_velocity + @band_half_width}
  end

  @spec color_for(%{
          velocity: number(),
          in_band: boolean(),
          thresholds: {number(), number()}
        }) :: String.t()
  def color_for(%{velocity: velocity, in_band: in_band, thresholds: {anemic, restriction}})
      when is_number(velocity) and is_boolean(in_band) and is_number(anemic) and
             is_number(restriction) do
    cond do
      velocity > restriction -> restriction_color(in_band)
      velocity < anemic -> anemic_color(in_band)
      true -> sufficient_color(in_band)
    end
  end

  @spec restriction_color(boolean()) :: String.t()
  def restriction_color(true), do: "hsl(48, 90%, 55%)"
  def restriction_color(false), do: "hsl(40, 90%, 32%)"

  @spec anemic_color(boolean()) :: String.t()
  def anemic_color(true), do: "hsl(205, 80%, 60%)"
  def anemic_color(false), do: "hsl(220, 75%, 30%)"

  @spec sufficient_color(boolean()) :: String.t()
  def sufficient_color(true), do: "hsl(125, 75%, 45%)"
  def sufficient_color(false), do: "hsl(125, 70%, 25%)"
end
