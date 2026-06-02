defmodule Afinados.Carburetion.FuelMap do
  @moduledoc "Fuel map: free area per throttle position plus the needle's unused span."

  @enforce_keys [:points, :h0, :h_max]
  defstruct [:points, :h0, :h_max, unused_span: nil]

  @type point :: %{position: 0..100, h: float(), free_area: float()}
  @type t :: %__MODULE__{
          points: [point(), ...],
          h0: float(),
          h_max: float(),
          unused_span: %{from: float(), to: float()} | nil
        }
end
