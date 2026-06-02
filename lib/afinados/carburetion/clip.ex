defmodule Afinados.Carburetion.Clip do
  @moduledoc "Needle clip position; 1 mm per position."

  @enforce_keys [:position]
  defstruct @enforce_keys

  @type t :: %__MODULE__{position: pos_integer()}
end
