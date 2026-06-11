defmodule Afinados.Seeds.Carburetion.NeedleJetTest do
  use ExUnit.Case, async: true

  alias Afinados.Seeds.Carburetion.NeedleJet

  test "bore follows the letter (0.05 mm) and number (0.005 mm) system" do
    assert NeedleJet.bore_um("159-P-4") == 2670
  end

  test "every needle jet has a positive bore" do
    assert Enum.all?(NeedleJet.data(), &(&1.bore_um > 0))
  end
end
