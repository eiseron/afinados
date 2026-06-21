defmodule Afinados.Carburetion.IntakeSizing.CommercialSize do
  @moduledoc "A commercial carburetor venturi diameter with its efficient RPM window."

  @enforce_keys [:diameter, :rpm_window]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          diameter: pos_integer(),
          rpm_window: {float(), float()}
        }
end
