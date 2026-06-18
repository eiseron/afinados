defmodule Afinados.SeedsTest do
  use Afinados.DataCase, async: true

  alias Afinados.Carburetion.Catalog
  alias Afinados.Seeds
  alias Afinados.Seeds.Carburetion.Needle

  describe "run/1" do
    test "returns :ok for every supported environment profile" do
      assert Enum.all?(~w(prod preview dev), &(Seeds.run(&1) == :ok))
    end

    test "makes a known needle resolvable through the catalog" do
      Seeds.run("prod")

      assert {:ok, %{part_number: "4D3"}} = Catalog.fetch_needle("mikuni", "4D3")
    end

    test "makes a known needle jet resolvable through the catalog" do
      Seeds.run("prod")

      assert {:ok, %{code: "159-P-5"}} = Catalog.fetch_needle_jet("mikuni", "159-P-5")
    end

    test "loads the complete needle reference dataset" do
      Seeds.run("prod")

      assert length(Catalog.list_needles("mikuni")) == length(Needle.data())
    end
  end
end
