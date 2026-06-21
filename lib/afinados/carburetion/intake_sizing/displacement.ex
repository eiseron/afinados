defmodule Afinados.Carburetion.IntakeSizing.Displacement do
  @moduledoc "Per-cylinder displacement (cm³); integer step, must be positive."

  @enforce_keys [:cc]
  defstruct @enforce_keys

  @type t :: %__MODULE__{cc: pos_integer()}

  @spec new(integer()) :: {:ok, t()} | :error
  def new(cc) when is_integer(cc) and cc > 0 do
    {:ok, %__MODULE__{cc: cc}}
  end

  def new(_cc), do: :error
end
