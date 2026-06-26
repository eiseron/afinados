defmodule Afinados.Carburetion.IntakeSizing.VelocityPalette do
  @moduledoc """
  Picks a solid color for a commercial venturi line from these signals:

    - whether the line's RPM sits inside the engine's working band
    - whether the gas velocity at that RPM exceeds the restriction threshold
    - whether the gas velocity falls below the anemic threshold
    - on carburetor only, whether the velocity sits in the soft band just above
      anemic where atomization gets marginal (cyan)

  Thresholds are dynamic: they slide with the engine's target velocity (derived from K
  in `IntakeSizing.target_velocity/1`). Electronic injection does not have a cyan
  band — fuel is sprayed by the injector, so low intake velocity does not impair
  atomization the way it does in a carburetor.
  """

  @band_half_width_up 30.0
  @band_half_width_down_carb 30.0
  @band_half_width_down_efi 40.0
  @atomization_floor 60.0
  @cyan_top_margin_below_target 5.0

  @spec band_half_width() :: float()
  def band_half_width, do: @band_half_width_up

  @spec thresholds(number()) :: {float(), float()}
  def thresholds(target_velocity), do: thresholds(target_velocity, :carburetor)

  @spec thresholds(number(), :carburetor | :injection) :: {float(), float()}
  def thresholds(target_velocity, :carburetor)
      when is_number(target_velocity) and target_velocity > 0 do
    {target_velocity - @band_half_width_down_carb, target_velocity + @band_half_width_up}
  end

  def thresholds(target_velocity, :injection)
      when is_number(target_velocity) and target_velocity > 0 do
    {target_velocity - @band_half_width_down_efi, target_velocity + @band_half_width_up}
  end

  @spec green_floor({number(), number()}, :carburetor | :injection) :: float()
  def green_floor({anemic, _restriction}, :injection), do: anemic * 1.0

  def green_floor({anemic, restriction}, :carburetor) when restriction > anemic do
    target = restriction - @band_half_width_up
    proposed = min(@atomization_floor, target - @cyan_top_margin_below_target)
    max(proposed, anemic) * 1.0
  end

  @spec color_for(%{
          velocity: number(),
          in_band: boolean(),
          thresholds: {number(), number()},
          induction: :carburetor | :injection
        }) :: String.t()
  def color_for(%{
        velocity: velocity,
        in_band: in_band,
        thresholds: {anemic, restriction},
        induction: induction
      })
      when is_number(velocity) and is_boolean(in_band) and is_number(anemic) and
             is_number(restriction) do
    cond do
      velocity > restriction -> restriction_color(in_band)
      velocity < anemic -> anemic_color(in_band)
      velocity < green_floor({anemic, restriction}, induction) -> fragile_color(in_band)
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

  @spec fragile_color(boolean()) :: String.t()
  def fragile_color(true), do: "hsl(180, 75%, 50%)"
  def fragile_color(false), do: "hsl(185, 70%, 28%)"
end
