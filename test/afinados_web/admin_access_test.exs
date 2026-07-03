defmodule AfinadosWeb.AdminAccessTest do
  use AfinadosWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias AfinadosWeb.Admin.RequireAdmin

  @plug AfinadosWeb.AdminAccessPlug
  @kid "team-key-1"
  @aud "admin-app-aud"
  @iss "https://eiseron-ops.cloudflareaccess.com"
  @now 1_000_000

  test "the admin page is reachable when the gate is disabled (dev/preview)", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/admin")

    assert html =~ "Admin"
  end

  describe "with the Cloudflare Access gate enabled" do
    setup do
      jwk = JOSE.JWK.generate_key({:rsa, 2048})
      {_meta, public} = JOSE.JWK.to_public_map(jwk)
      public = Map.put(public, "kid", @kid)

      Application.put_env(:afinados, @plug,
        enabled: true,
        audiences: [@aud],
        issuer: @iss,
        jwks: [public],
        now: @now
      )

      on_exit(fn -> Application.put_env(:afinados, @plug, enabled: false) end)

      %{jwk: jwk}
    end

    test "refuses a request without an Access assertion", %{conn: conn} do
      conn = get(conn, "/admin")

      assert conn.status == 403
      assert conn.halted
    end

    test "refuses a token with a wrong audience", %{conn: conn, jwk: jwk} do
      conn = request(conn, jwk, %{"aud" => "other"})

      assert conn.status == 403
    end

    test "refuses an expired token", %{conn: conn, jwk: jwk} do
      conn = request(conn, jwk, %{"exp" => @now - 1})

      assert conn.status == 403
    end

    test "refuses a token forged with a different key", %{conn: conn} do
      attacker = JOSE.JWK.generate_key({:rsa, 2048})
      conn = request(conn, attacker, %{})

      assert conn.status == 403
    end

    test "allows a request carrying a valid Access assertion", %{conn: conn, jwk: jwk} do
      conn = request(conn, jwk, %{"email" => "op@eiseron.com"})

      assert html_response(conn, 200) =~ "Admin"
    end
  end

  describe "RequireAdmin on_mount hook" do
    test "halts and redirects when the gate is enabled and the session is unauthenticated" do
      with_enabled_gate(fn ->
        assert {:halt, %{redirected: {:redirect, _}}} =
                 RequireAdmin.on_mount(:default, %{}, %{}, socket())
      end)
    end

    test "continues when the session was authenticated by the plug" do
      with_enabled_gate(fn ->
        session = %{"admin_email" => "op@eiseron.com"}

        assert {:cont, %{assigns: %{admin_email: "op@eiseron.com"}}} =
                 RequireAdmin.on_mount(:default, %{}, session, socket())
      end)
    end

    test "continues when the gate is disabled" do
      assert {:cont, _socket} = RequireAdmin.on_mount(:default, %{}, %{}, socket())
    end
  end

  defp request(conn, jwk, overrides) do
    claims = Map.merge(%{"iss" => @iss, "aud" => @aud, "exp" => @now + 60}, overrides)

    {_alg, token} =
      jwk
      |> JOSE.JWT.sign(%{"alg" => "RS256", "kid" => @kid}, claims)
      |> JOSE.JWS.compact()

    conn |> put_req_header("cf-access-jwt-assertion", token) |> get("/admin")
  end

  defp with_enabled_gate(fun) do
    Application.put_env(:afinados, @plug, enabled: true, audiences: [], issuer: @iss)
    fun.()
  after
    Application.put_env(:afinados, @plug, enabled: false)
  end

  defp socket, do: %Phoenix.LiveView.Socket{}
end
