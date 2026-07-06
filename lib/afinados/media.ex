defmodule Afinados.Media do
  @moduledoc false

  @spec put(String.t(), binary(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def put(key, body, content_type), do: adapter().put(key, body, content_type)

  @spec key(String.t()) :: String.t()
  def key(filename) do
    ext = filename |> Path.extname() |> String.downcase()
    "offers/#{Ecto.UUID.generate()}#{ext}"
  end

  defp adapter do
    Application.get_env(:afinados, __MODULE__, [])[:adapter] || Afinados.Media.R2
  end

  @callback put(key :: String.t(), body :: binary(), content_type :: String.t()) ::
              {:ok, String.t()} | {:error, term()}
end
