defmodule Afinados.Carburetion.IntakeSizing.EfficiencyZone do
  @moduledoc "Efficiency zone: the diameter envelope spanning Ve_min..Ve_max across RPM."

  @enforce_keys [:envelope]
  defstruct @enforce_keys

  @type point :: %{rpm: number(), diameter: float()}

  @type t :: %__MODULE__{
          envelope: %{lower: [point()], upper: [point()]}
        }
end
