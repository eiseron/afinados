defmodule Afinados.Carburetion.Setup do
  @moduledoc "Resolved setup (in mm): pure input to the carburetion core."

  alias Afinados.Carburetion.{Clip, Needle, NeedleJet, Shim, Venturi}

  @enforce_keys [:needle, :needle_jet, :clip, :shim, :venturi]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          needle: Needle.t(),
          needle_jet: NeedleJet.t(),
          clip: Clip.t(),
          shim: Shim.t(),
          venturi: Venturi.t()
        }
end
