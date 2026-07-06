defmodule Afinados.Media.R2 do
  @moduledoc false

  @behaviour Afinados.Media

  @impl true
  def put(key, body, content_type) do
    config = config()
    url = "#{config.endpoint}/#{config.bucket}/#{key}"

    request =
      Req.new(
        [
          method: :put,
          url: url,
          body: body,
          headers: [{"content-type", content_type}],
          aws_sigv4: [
            service: "s3",
            region: "auto",
            access_key_id: config.access_key_id,
            secret_access_key: config.secret_access_key
          ]
        ] ++ config.req_options
      )

    case Req.request(request) do
      {:ok, %Req.Response{status: status}} when status in 200..299 ->
        {:ok, "#{config.public_base_url}/#{key}"}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:unexpected_status, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp config do
    env = Application.fetch_env!(:afinados, __MODULE__)

    %{
      bucket: Keyword.fetch!(env, :bucket),
      endpoint: Keyword.fetch!(env, :endpoint),
      access_key_id: Keyword.fetch!(env, :access_key_id),
      secret_access_key: Keyword.fetch!(env, :secret_access_key),
      public_base_url: Keyword.fetch!(env, :public_base_url),
      req_options: Keyword.get(env, :req_options, [])
    }
  end
end
