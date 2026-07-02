defmodule AfinadosWeb.Locale do
  @moduledoc "Resolves the request locale from the session, then Accept-Language, then the default, and sets it for Gettext."

  import Plug.Conn

  @locales ~w(pt_BR en)
  @default "pt_BR"

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = determine_locale(get_session(conn, :locale), accept_language(conn))

    Gettext.put_locale(AfinadosWeb.Gettext, locale)
    put_session(conn, :locale, locale)
  end

  def locales, do: @locales

  def default, do: @default

  def supported?(locale), do: locale in @locales

  def determine_locale(session_locale, accept_language) do
    cond do
      supported?(session_locale) -> session_locale
      prefers_english?(accept_language) -> "en"
      true -> @default
    end
  end

  defp prefers_english?(nil), do: false
  defp prefers_english?(header), do: String.starts_with?(header, "en")

  defp accept_language(conn) do
    conn |> get_req_header("accept-language") |> List.first()
  end
end
