defmodule Afinados.Seeds.Carburetion.NeedleJet do
  @moduledoc "Frozen Mikuni needle-jet reference data; bore derived from the letter/number coding system."

  alias Afinados.Carburetion.Catalog
  alias Afinados.Repo

  @letter_bore_um %{"N" => 2550, "O" => 2600, "P" => 2650, "Q" => 2700, "R" => 2750}

  @codes ~w(
    159-N-4 159-N-8 159-O-0 159-O-2 159-O-4 159-O-5 159-P-0 159-P-5 159-P-8
    159-Q-2 159-Q-4 159-Q-6 159-R-0 159-R-2 159-R-4 159-R-5 159-R-6 159-R-8
  )

  @spec data() :: [map()]
  def data do
    Enum.map(@codes, fn code ->
      %{code: code, manufacturer: "mikuni", bore_um: bore_um(code)}
    end)
  end

  @spec bore_um(String.t()) :: integer()
  def bore_um(code) do
    [_series, letter, number] = String.split(code, "-")
    @letter_bore_um[letter] + String.to_integer(number) * 5
  end

  @spec seed() :: :ok
  def seed do
    Enum.each(data(), fn attrs ->
      %Catalog.NeedleJet{}
      |> Catalog.NeedleJet.changeset(attrs)
      |> Repo.insert!(
        on_conflict: {:replace_all_except, [:id, :inserted_at]},
        conflict_target: :code
      )
    end)
  end
end
