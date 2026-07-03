defmodule AfinadosWeb.DocsTest do
  use ExUnit.Case, async: false

  alias AfinadosWeb.Docs

  setup do
    original = Application.get_env(:afinados, :docs)
    locale = Gettext.get_locale(AfinadosWeb.Gettext)

    on_exit(fn ->
      if original, do: Application.put_env(:afinados, :docs, original)
      Gettext.put_locale(AfinadosWeb.Gettext, locale)
    end)

    :ok
  end

  defp release_version do
    case :afinados |> Application.spec(:vsn) |> to_string() |> String.split(".") do
      [major, minor | _] -> "v#{major}.#{minor}"
      _ -> ""
    end
  end

  test "the home URL uses the official host, the pt docs path, and the release version" do
    Application.put_env(:afinados, :docs, host: "https://afinados.io")
    Gettext.put_locale(AfinadosWeb.Gettext, "pt_BR")

    assert Docs.url() == "https://afinados.io/docs/#{release_version()}"
  end

  test "a page URL mirrors the docs/ tree under the versioned pt path" do
    Application.put_env(:afinados, :docs, host: "https://afinados.io")
    Gettext.put_locale(AfinadosWeb.Gettext, "pt_BR")

    assert Docs.url("fuel-passage-area/interface") ==
             "https://afinados.io/docs/#{release_version()}/fuel-passage-area/interface"
  end

  test "the English locale resolves to the en/docs path" do
    Application.put_env(:afinados, :docs, host: "https://afinados.io")
    Gettext.put_locale(AfinadosWeb.Gettext, "en")

    assert Docs.url("intake-sizing/interface") ==
             "https://afinados.io/en/docs/#{release_version()}/intake-sizing/interface"
  end

  test "the configured host wins and its trailing slash is dropped" do
    Application.put_env(:afinados, :docs, host: "https://staging.afinados.io/")
    Gettext.put_locale(AfinadosWeb.Gettext, "pt_BR")

    assert Docs.url("fuel-passage-area/interface") ==
             "https://staging.afinados.io/docs/#{release_version()}/fuel-passage-area/interface"
  end

  test "the version always tracks the running release" do
    Application.put_env(:afinados, :docs, host: "https://afinados.io")
    Gettext.put_locale(AfinadosWeb.Gettext, "pt_BR")

    assert Docs.url("fuel-passage-area/interface") =~
             ~r{/docs/v\d+\.\d+/fuel-passage-area/interface\z}
  end
end
