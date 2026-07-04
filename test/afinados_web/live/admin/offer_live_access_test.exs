defmodule AfinadosWeb.Admin.OfferLiveAccessTest do
  use AfinadosWeb.ConnCase, async: false

  alias Afinados.Offers

  setup do
    original = Application.get_env(:afinados, AfinadosWeb.AdminAccessPlug, [])
    Application.put_env(:afinados, AfinadosWeb.AdminAccessPlug, enabled: true)
    on_exit(fn -> Application.put_env(:afinados, AfinadosWeb.AdminAccessPlug, original) end)
    :ok
  end

  describe "with the admin gate enabled and no Access assertion" do
    test "refuses the offers index", %{conn: conn} do
      assert conn |> get(~p"/admin/offers") |> Map.fetch!(:status) == 403
    end

    test "refuses the new offer form", %{conn: conn} do
      assert conn |> get(~p"/admin/offers/new") |> Map.fetch!(:status) == 403
    end

    test "refuses the edit offer form", %{conn: conn} do
      {:ok, offer} =
        Offers.create_offer(%{
          locale: "pt_BR",
          title: "Gated",
          target_url: "https://example.com/x",
          surfaces: ["hub_shelf"]
        })

      assert conn |> get(~p"/admin/offers/#{offer}/edit") |> Map.fetch!(:status) == 403
    end
  end
end
