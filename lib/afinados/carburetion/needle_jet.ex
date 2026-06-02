defmodule Afinados.Carburetion.NeedleJet do
  @moduledoc "Needle jet: standardized-bore tube the needle enters."

  @enforce_keys [:code, :bore_mm]
  defstruct @enforce_keys

  @type t :: %__MODULE__{code: String.t(), bore_mm: float()}
end
