defmodule Afinados.Carburetion.HighJet do
  @moduledoc "Main jet: a series restriction with the annular passage; its free area limits the variable area."

  @enforce_keys [:number, :free_area_mm2]
  defstruct @enforce_keys

  @type t :: %__MODULE__{number: integer(), free_area_mm2: float()}
end
