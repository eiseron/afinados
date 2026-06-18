defmodule Afinados.Seeds.CatalogSeedTest do
  use Afinados.DataCase, async: true

  alias Afinados.Carburetion.Catalog
  alias Afinados.Seeds.Carburetion.{Needle, NeedleJet}

  test "seeding the catalog makes a known needle resolvable" do
    Needle.seed()

    assert {:ok, %{part_number: "4D3"}} = Catalog.fetch_needle("4D3")
  end

  test "seeding the catalog makes a known needle jet resolvable" do
    NeedleJet.seed()

    assert {:ok, %{code: "159-P-5"}} = Catalog.fetch_needle_jet("159-P-5")
  end

  test "seeding twice stays idempotent" do
    Needle.seed()
    Needle.seed()

    assert length(Catalog.list_needles("mikuni")) == length(Needle.data())
  end
end
