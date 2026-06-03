defmodule Afinados.Carburetion.LowJet do
  @moduledoc "Pilot jet: a constant free-area floor added across the whole curve (idle circuit)."

  @enforce_keys [:number, :free_area_mm2]
  defstruct @enforce_keys

  @type t :: %__MODULE__{number: float(), free_area_mm2: float()}
end
