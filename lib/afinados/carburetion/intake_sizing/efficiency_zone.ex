defmodule Afinados.Carburetion.IntakeSizing.EfficiencyZone do
  @moduledoc "Efficiency zone: the envelope (Ve_min..Ve_max) and the selected Ve curve across RPM."

  @enforce_keys [:envelope, :curve]
  defstruct @enforce_keys

  @type point :: %{rpm: number(), diameter: float()}

  @type t :: %__MODULE__{
          envelope: %{lower: [point()], upper: [point()]},
          curve: [point()]
        }
end
