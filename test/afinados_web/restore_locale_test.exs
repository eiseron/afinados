defmodule AfinadosWeb.RestoreLocaleTest do
  use ExUnit.Case, async: true

  alias AfinadosWeb.RestoreLocale

  test "restores the session locale into the LiveView process" do
    Gettext.put_locale(AfinadosWeb.Gettext, "pt_BR")

    {:cont, _socket} =
      RestoreLocale.on_mount(:default, %{}, %{"locale" => "en"}, %Phoenix.LiveView.Socket{})

    assert Gettext.get_locale(AfinadosWeb.Gettext) == "en"
  end

  test "falls back to the default when the session carries no locale" do
    Gettext.put_locale(AfinadosWeb.Gettext, "en")

    {:cont, _socket} =
      RestoreLocale.on_mount(:default, %{}, %{}, %Phoenix.LiveView.Socket{})

    assert Gettext.get_locale(AfinadosWeb.Gettext) == "pt_BR"
  end
end
