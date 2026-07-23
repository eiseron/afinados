defmodule Afinados.ReleaseTest do
  use ExUnit.Case, async: false

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    original = Application.get_env(:afinados, :observability, [])
    on_exit(fn -> Application.put_env(:afinados, :observability, original) end)
    :ok
  end

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

  describe "current_profile/0" do
    test "reports prod when no observability env is configured" do
      Application.put_env(:afinados, :observability, [])
      assert Afinados.Release.current_profile() == "prod"
    end

    test "reports the deploy environment baked into config/runtime.exs" do
      Application.put_env(:afinados, :observability, env: :preview)
      assert Afinados.Release.current_profile() == "preview"
    end
  end

  describe "setup/0 (real migration, sandboxed)" do
    test "runs migrate against the sandboxed repo and skips seeding on prod" do
      Sandbox.checkout(Afinados.Repo)
      Application.put_env(:afinados, :observability, env: :prod)
      assert Afinados.Release.setup() == nil
    end
  end

  describe "seed_for_current_profile/0" do
    test "skips seeding for prod, so setup/0 stays a safe no-op on a normal prod deploy" do
      Application.put_env(:afinados, :observability, env: :prod)
      assert Afinados.Release.seed_for_current_profile() == nil
    end

    test "skips seeding for a deploy profile that is neither preview nor dev" do
      Application.put_env(:afinados, :observability, env: :staging)
      assert Afinados.Release.seed_for_current_profile() == nil
    end
  end
end
