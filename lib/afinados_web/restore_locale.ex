defmodule AfinadosWeb.RestoreLocale do
  @moduledoc "on_mount hook that restores the session locale in the LiveView process, which does not share the plug's Gettext locale."

  def on_mount(:default, _params, session, socket) do
    locale = session["locale"] || AfinadosWeb.Locale.default()

    if AfinadosWeb.Locale.supported?(locale) do
      Gettext.put_locale(AfinadosWeb.Gettext, locale)
    end

    {:cont, socket}
  end
end
