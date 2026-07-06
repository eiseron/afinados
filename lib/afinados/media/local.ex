defmodule Afinados.Media.Local do
  @moduledoc false

  @behaviour Afinados.Media

  @impl true
  def put(key, body, _content_type) do
    path = Path.join(dir(), key)
    :ok = :filelib.ensure_dir(to_charlist(path))

    case :file.write_file(path, body) do
      :ok -> {:ok, "#{base_url()}/uploads/#{key}"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp dir do
    Application.get_env(:afinados, __MODULE__)[:dir] ||
      Application.app_dir(:afinados, "priv/static/uploads")
  end

  defp base_url, do: AfinadosWeb.Endpoint.url()
end
