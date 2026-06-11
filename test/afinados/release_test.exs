defmodule Afinados.ReleaseTest do
  use ExUnit.Case, async: true

  describe "seed/1" do
    test "rejects a profile outside the allowlist before touching the filesystem" do
      assert_raise ArgumentError, ~r/unknown seed profile/, fn ->
        Afinados.Release.seed("../../evil")
      end
    end

    test "rejects an arbitrary unknown profile" do
      assert_raise ArgumentError, ~r/unknown seed profile/, fn ->
        Afinados.Release.seed("staging")
      end
    end
  end
end
