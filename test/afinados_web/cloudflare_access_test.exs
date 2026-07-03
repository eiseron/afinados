defmodule AfinadosWeb.CloudflareAccessTest do
  use ExUnit.Case, async: true

  alias AfinadosWeb.CloudflareAccess

  @kid "team-key-1"
  @aud "admin-app-aud"
  @iss "https://eiseron-ops.cloudflareaccess.com"
  @now 1_000_000

  setup do
    jwk = JOSE.JWK.generate_key({:rsa, 2048})
    {_meta, public} = JOSE.JWK.to_public_map(jwk)
    public = Map.put(public, "kid", @kid)

    %{
      jwk: jwk,
      public: public,
      config: [audiences: [@aud], issuer: @iss, jwks: [public], now: @now]
    }
  end

  defp sign(jwk, claims, kid \\ @kid) do
    {_alg, token} =
      jwk
      |> JOSE.JWT.sign(%{"alg" => "RS256", "kid" => kid}, claims)
      |> JOSE.JWS.compact()

    token
  end

  defp claims(overrides \\ %{}) do
    Map.merge(%{"iss" => @iss, "aud" => @aud, "exp" => @now + 60}, overrides)
  end

  test "accepts a token signed by the team key with a valid issuer and audience", %{
    jwk: jwk,
    config: config
  } do
    token = sign(jwk, claims(%{"email" => "op@eiseron.com"}))

    assert {:ok, %{"email" => "op@eiseron.com"}} = CloudflareAccess.verify(token, config)
  end

  test "rejects a token whose issuer is wrong", %{jwk: jwk, config: config} do
    token = sign(jwk, claims(%{"iss" => "https://attacker.cloudflareaccess.com"}))

    assert {:error, :bad_issuer} = CloudflareAccess.verify(token, config)
  end

  test "rejects a token with no issuer claim", %{jwk: jwk, config: config} do
    token = sign(jwk, %{"aud" => @aud, "exp" => @now + 60})

    assert {:error, :bad_issuer} = CloudflareAccess.verify(token, config)
  end

  test "rejects a token whose audience is not allowed", %{jwk: jwk, config: config} do
    token = sign(jwk, claims(%{"aud" => "another-app"}))

    assert {:error, :bad_aud} = CloudflareAccess.verify(token, config)
  end

  test "rejects an expired token", %{jwk: jwk, config: config} do
    token = sign(jwk, claims(%{"exp" => @now - 1}))

    assert {:error, :expired} = CloudflareAccess.verify(token, config)
  end

  test "rejects a token whose key id is unknown", %{jwk: jwk, config: config} do
    token = sign(jwk, claims(), "unknown-kid")

    assert {:error, :unknown_kid} = CloudflareAccess.verify(token, config)
  end

  test "rejects a token forged with a different key under a known key id", %{config: config} do
    attacker = JOSE.JWK.generate_key({:rsa, 2048})
    token = sign(attacker, claims())

    assert {:error, :bad_signature} = CloudflareAccess.verify(token, config)
  end

  test "rejects a malformed token", %{config: config} do
    assert {:error, :bad_header} = CloudflareAccess.verify("not-a-jwt", config)
  end

  test "rejects a validly signed token when no audiences are configured", %{
    jwk: jwk,
    config: config
  } do
    token = sign(jwk, claims())

    assert {:error, :bad_aud} =
             CloudflareAccess.verify(token, Keyword.put(config, :audiences, []))
  end

  describe "fetching team keys from the certs url" do
    test "verifies a token using keys fetched from the certs url", %{jwk: jwk, public: public} do
      url = uniq_url()
      config = base(certs_url: url, fetcher: counting_fetcher([public]))

      assert {:ok, _} = CloudflareAccess.verify(sign(jwk, claims()), config)
      assert_received {:fetched, ^url}
    end

    test "caches fetched keys within the ttl", %{jwk: jwk, public: public} do
      url = uniq_url()
      config = base(certs_url: url, fetcher: counting_fetcher([public]))

      assert {:ok, _} = CloudflareAccess.verify(sign(jwk, claims()), config)
      assert {:ok, _} = CloudflareAccess.verify(sign(jwk, claims()), config)

      assert_received {:fetched, ^url}
      refute_received {:fetched, ^url}
    end

    test "does not cache a failed fetch", %{jwk: jwk, public: public} do
      url = uniq_url()

      assert {:error, :unknown_kid} =
               CloudflareAccess.verify(
                 sign(jwk, claims()),
                 base(certs_url: url, fetcher: counting_fetcher([]))
               )

      assert {:ok, _} =
               CloudflareAccess.verify(
                 sign(jwk, claims()),
                 base(certs_url: url, fetcher: counting_fetcher([public]))
               )
    end

    test "refetches keys after the ttl expires", %{jwk: jwk, public: public} do
      url = uniq_url()
      fetcher = counting_fetcher([public])
      token = sign(jwk, claims(%{"exp" => @now + 100_000}))

      assert {:ok, _} = CloudflareAccess.verify(token, base(certs_url: url, fetcher: fetcher))

      assert {:ok, _} =
               CloudflareAccess.verify(
                 token,
                 base(certs_url: url, fetcher: fetcher, now: @now + 3601)
               )

      assert_received {:fetched, ^url}
      assert_received {:fetched, ^url}
    end

    test "the default fetcher reads the JWKS over http", %{jwk: jwk, public: public} do
      Req.Test.stub(__MODULE__, fn conn -> Req.Test.json(conn, %{"keys" => [public]}) end)
      config = base(certs_url: uniq_url(), req_options: [plug: {Req.Test, __MODULE__}])

      assert {:ok, _} = CloudflareAccess.verify(sign(jwk, claims()), config)
    end
  end

  defp base(extra) do
    Keyword.merge([audiences: [@aud], issuer: @iss, now: @now], extra)
  end

  defp uniq_url,
    do: "https://team-#{System.unique_integer([:positive])}.cloudflareaccess.com/certs"

  defp counting_fetcher(keys) do
    parent = self()

    fn url ->
      send(parent, {:fetched, url})
      keys
    end
  end
end
