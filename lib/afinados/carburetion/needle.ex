defmodule Afinados.Carburetion.Needle do
  @moduledoc "Jet needle: straight section up to the first taper point, then a tapered profile across stations."

  @enforce_keys [
    :part_number,
    :total_length_mm,
    :taper_points_mm,
    :station_diameters_mm,
    :num_clips
  ]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          part_number: String.t(),
          total_length_mm: float(),
          taper_points_mm: [float(), ...],
          station_diameters_mm: [float(), ...],
          num_clips: pos_integer()
        }
end
