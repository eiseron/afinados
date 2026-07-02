defmodule AfinadosWeb.LocaleController do
  use AfinadosWeb, :controller

  def update(conn, %{"locale" => locale}) do
    conn
    |> put_locale_in_session(locale)
    |> redirect(to: return_path(conn))
  end

  defp put_locale_in_session(conn, locale) do
    if AfinadosWeb.Locale.supported?(locale) do
      put_session(conn, :locale, locale)
    else
      conn
    end
  end

  defp return_path(conn) do
    conn |> get_req_header("referer") |> List.first() |> parse_return_path()
  end

  defp parse_return_path(referer) when is_binary(referer) do
    referer |> URI.parse() |> Map.get(:path) |> local_path()
  end

  defp parse_return_path(_referer), do: "/"

  defp local_path("//" <> _rest), do: "/"
  defp local_path("/" <> _rest = path), do: path
  defp local_path(_path), do: "/"
end
