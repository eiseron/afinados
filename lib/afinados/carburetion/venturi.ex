defmodule Afinados.Carburetion.Venturi do
  @moduledoc "Venturi (mm): carburetor attribute; defines the needle travel range."

  @enforce_keys [:mm]
  defstruct @enforce_keys

  @type t :: %__MODULE__{mm: float()}
end
