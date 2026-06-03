defmodule Afinados.Carburetion.Setup do
  @moduledoc "Resolved setup (in mm/mm²): pure input to the carburetion core."

  alias Afinados.Carburetion.{Clip, HighJet, LowJet, Needle, NeedleJet, Shim, Venturi}

  @enforce_keys [:needle, :needle_jet, :high_jet, :low_jet, :clip, :shim, :venturi]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          needle: Needle.t(),
          needle_jet: NeedleJet.t(),
          high_jet: HighJet.t(),
          low_jet: LowJet.t(),
          clip: Clip.t(),
          shim: Shim.t(),
          venturi: Venturi.t()
        }
end
