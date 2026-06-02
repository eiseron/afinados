defmodule Afinados.Carburetion.Shim do
  @moduledoc "Shim: fine needle offset, 0.01 mm step, persisted in hundredths."

  defstruct hundredths: 0

  @type t :: %__MODULE__{hundredths: non_neg_integer()}
end
