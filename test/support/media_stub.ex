defmodule Afinados.MediaStub do
  @moduledoc false

  @behaviour Afinados.Media

  @impl true
  def put(key, _body, _content_type), do: {:ok, "https://img.test.local/#{key}"}
end
