defmodule Afinados.IdentityTest do
  use Afinados.DataCase, async: true

  alias Afinados.Identity
  alias Afinados.Identity.User

  describe "generate_token/0" do
    test "produces distinct tokens" do
      refute Identity.generate_token() == Identity.generate_token()
    end
  end

  describe "hash_token/1" do
    test "is deterministic for the same token" do
      token = Identity.generate_token()

      assert Identity.hash_token(token) == Identity.hash_token(token)
    end
  end

  describe "ensure_user_for_token/1" do
    test "creates a guest user on first use" do
      user = Identity.ensure_user_for_token(Identity.generate_token())

      assert %User{type: "guest", email: nil, password_hash: nil} = user
    end

    test "returns the same user for a repeated token" do
      token = Identity.generate_token()
      first = Identity.ensure_user_for_token(token)

      assert Identity.ensure_user_for_token(token).id == first.id
    end
  end

  describe "user_for_token/1" do
    test "returns nil for an unknown token" do
      assert Identity.user_for_token("nope") == nil
    end

    test "returns the user once the token is established" do
      token = Identity.generate_token()
      user = Identity.ensure_user_for_token(token)

      assert Identity.user_for_token(token).id == user.id
    end
  end
end
