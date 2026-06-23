defmodule Afinados.Carburetion.IntakeSizing.VelocityPalette do
  @moduledoc """
  Picks a solid color for a commercial venturi line based on three signals:

    - whether the line's RPM window overlaps the engine's typical RPM band
    - whether the gas velocity through the venturi exceeds the restriction threshold
    - whether the gas velocity through the venturi falls below the anemic threshold

  Result table:

    | restricts | anemic | in band | color       |
    |-----------|--------|---------|-------------|
    | yes       | —      | yes     | yellow      |
    | yes       | —      | no      | dark yellow |
    | no        | yes    | yes     | light blue  |
    | no        | yes    | no      | dark blue   |
    | no        | no     | yes     | green       |
    | no        | no     | no      | dark green  |
  """

  @anemic_threshold 60.0
  @restriction_threshold 130.0

  @spec color_for(%{velocity: number(), in_band: boolean()}) :: String.t()
  def color_for(%{velocity: velocity, in_band: in_band})
      when is_number(velocity) and is_boolean(in_band) do
    cond do
      velocity > @restriction_threshold -> restriction_color(in_band)
      velocity < @anemic_threshold -> anemic_color(in_band)
      true -> sufficient_color(in_band)
    end
  end

  @spec anemic_threshold() :: float()
  def anemic_threshold, do: @anemic_threshold

  @spec restriction_threshold() :: float()
  def restriction_threshold, do: @restriction_threshold

  defp restriction_color(true), do: "hsl(48, 90%, 55%)"
  defp restriction_color(false), do: "hsl(40, 90%, 32%)"

  defp anemic_color(true), do: "hsl(205, 80%, 60%)"
  defp anemic_color(false), do: "hsl(220, 75%, 30%)"

  defp sufficient_color(true), do: "hsl(125, 75%, 45%)"
  defp sufficient_color(false), do: "hsl(125, 70%, 25%)"
end
