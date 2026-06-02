defmodule Afinados.GarageTest do
  use Afinados.DataCase, async: true

  alias Afinados.Garage
  alias Afinados.Identity

  defp guest, do: Identity.ensure_user_for_token(Identity.generate_token())

  describe "default_for/1" do
    test "creates a garage owned by the user when none exists" do
      user = guest()

      assert Garage.default_for(user).user_id == user.id
    end

    test "returns the existing garage instead of creating another" do
      user = guest()
      first = Garage.default_for(user)

      assert Garage.default_for(user).id == first.id
    end
  end

  describe "list_for/1" do
    test "lists only the user's own garages" do
      user = guest()
      garage = Garage.default_for(user)
      Garage.default_for(guest())

      assert Enum.map(Garage.list_for(user), & &1.id) == [garage.id]
    end
  end
end
