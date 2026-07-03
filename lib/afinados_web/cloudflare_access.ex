defmodule AfinadosWeb.CloudflareAccess do
  @moduledoc """
  Verifies a Cloudflare Access application token (the `Cf-Access-Jwt-Assertion`
  header): RS256 signature against the team's JWKS plus the `aud` and `exp`
  claims. Public keys are fetched from the team certs URL and cached; an unseen
  `kid` forces a refetch, so key rotation is handled.
  """

  @cache_ttl_seconds 3600

  @spec verify(String.t(), keyword()) :: {:ok, map()} | {:error, atom()}
  def verify(token, config) when is_binary(token) do
    audiences = Keyword.fetch!(config, :audiences)

    with {:ok, kid} <- token_kid(token),
         {:ok, jwk} <- key_for(kid, config),
         {:ok, claims} <- verify_signature(token, jwk),
         :ok <- verify_iss(claims, config),
         :ok <- verify_aud(claims, audiences),
         :ok <- verify_exp(claims, now(config)) do
      {:ok, claims}
    end
  end

  def verify(_token, _config), do: {:error, :invalid_token}

  defp verify_iss(%{"iss" => iss}, config) do
    if iss == Keyword.fetch!(config, :issuer), do: :ok, else: {:error, :bad_issuer}
  end

  defp verify_iss(_claims, _config), do: {:error, :bad_issuer}

  defp token_kid(token) do
    with [header_b64 | _] <- String.split(token, "."),
         {:ok, json} <- Base.url_decode64(header_b64, padding: false),
         {:ok, %{"kid" => kid}} <- Jason.decode(json) do
      {:ok, kid}
    else
      _ -> {:error, :bad_header}
    end
  end

  defp verify_signature(token, jwk_map) do
    jwk = JOSE.JWK.from_map(jwk_map)

    case JOSE.JWT.verify_strict(jwk, ["RS256"], token) do
      {true, %JOSE.JWT{fields: claims}, _} -> {:ok, claims}
      _ -> {:error, :bad_signature}
    end
  end

  defp verify_aud(%{"aud" => aud}, audiences) do
    presented = List.wrap(aud)

    if Enum.any?(presented, &(&1 in audiences)), do: :ok, else: {:error, :bad_aud}
  end

  defp verify_aud(_claims, _audiences), do: {:error, :bad_aud}

  defp verify_exp(%{"exp" => exp}, now) when is_integer(exp) and exp > 0 do
    if exp > now, do: :ok, else: {:error, :expired}
  end

  defp verify_exp(_claims, _now), do: {:error, :no_exp}

  defp now(config), do: Keyword.get(config, :now, System.system_time(:second))

  defp key_for(kid, config) do
    case Keyword.get(config, :jwks) do
      nil -> fetch_key(kid, config)
      keys -> find_key(keys, kid)
    end
  end

  defp fetch_key(kid, config) do
    url = Keyword.fetch!(config, :certs_url)

    case find_key(cached_keys(url, config), kid) do
      {:ok, jwk} -> {:ok, jwk}
      {:error, :unknown_kid} -> find_key(refresh_keys(url, config), kid)
    end
  end

  defp find_key(keys, kid) do
    case Enum.find(keys, &(&1["kid"] == kid)) do
      nil -> {:error, :unknown_kid}
      jwk -> {:ok, jwk}
    end
  end

  defp cached_keys(url, config) do
    case :persistent_term.get({__MODULE__, url}, nil) do
      {fetched_at, keys} ->
        if now(config) - fetched_at < @cache_ttl_seconds,
          do: keys,
          else: refresh_keys(url, config)

      nil ->
        refresh_keys(url, config)
    end
  end

  defp refresh_keys(url, config) do
    fetch = Keyword.get(config, :fetcher, fn u -> http_get_keys(u, config) end)

    case fetch.(url) do
      [] -> []
      keys -> cache_keys(url, keys, config)
    end
  end

  defp cache_keys(url, keys, config) do
    :persistent_term.put({__MODULE__, url}, {now(config), keys})
    keys
  end

  defp http_get_keys(url, config) do
    options = Keyword.merge([url: url, retry: :transient], Keyword.get(config, :req_options, []))

    case Req.get(options) do
      {:ok, %{status: 200, body: %{"keys" => keys}}} when is_list(keys) -> keys
      _ -> []
    end
  end
end
