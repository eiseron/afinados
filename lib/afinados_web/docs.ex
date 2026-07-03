defmodule AfinadosWeb.Docs do
  @moduledoc "Builds locale- and version-aware URLs into the published Afinados documentation, so the app links to the docs matching its release."

  @default_host "https://afinados.io"

  @doc """
  URL of a published documentation page.

  `page` mirrors the `docs/` source tree (for example `"fuel-passage-area/interface"`);
  omit it for the documentation home. The host comes from configuration (official host
  by default), the version from the running release, and the locale prefix from the
  active Gettext locale.
  """
  def url(page \\ "") do
    [host(), locale_segment(), release_version(), String.trim(page, "/")]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("/")
  end

  defp host do
    :afinados
    |> Application.get_env(:docs, [])
    |> Keyword.get(:host, @default_host)
    |> String.trim_trailing("/")
  end

  defp locale_segment do
    case Gettext.get_locale(AfinadosWeb.Gettext) do
      "en" -> "en/docs"
      _ -> "docs"
    end
  end

  defp release_version do
    [major, minor | _] = :afinados |> Application.spec(:vsn) |> to_string() |> String.split(".")
    "v#{major}.#{minor}"
  end
end
