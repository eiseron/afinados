defmodule Afinados.Carburetion.IntakeSizing.EngineConfig do
  @moduledoc "Engine configuration: gas velocity constant, carburetors, cylinders, and boost."

  @enforce_keys [:k, :carbs, :cylinders, :boost]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          k: float(),
          carbs: pos_integer(),
          cylinders: pos_integer(),
          boost: float()
        }

  @spec new(map()) :: {:ok, t()} | :error
  def new(%{k: k, carbs: carbs, cylinders: cylinders, boost: boost})
      when is_number(k) and k > 0 and
             is_integer(carbs) and carbs >= 1 and
             is_integer(cylinders) and cylinders >= 1 and
             is_number(boost) and boost > -1 do
    {:ok, %__MODULE__{k: k, carbs: carbs, cylinders: cylinders, boost: boost * 1.0}}
  end

  def new(_params), do: :error

  @spec p_abs(t()) :: float()
  def p_abs(%__MODULE__{boost: boost}), do: 1.0 + boost
end
