defmodule AfinadosWeb.LocaleTest do
  use ExUnit.Case, async: true

  alias AfinadosWeb.Locale

  describe "determine_locale/2" do
    test "keeps a supported English session locale over the header" do
      assert Locale.determine_locale("en", "pt-BR,pt;q=0.9") == "en"
    end

    test "keeps a supported Portuguese session locale over the header" do
      assert Locale.determine_locale("pt_BR", "en-US,en;q=0.9") == "pt_BR"
    end

    test "honours an English Accept-Language when there is no session locale" do
      assert Locale.determine_locale(nil, "en-US,en;q=0.9") == "en"
    end

    test "keeps pt_BR for a Portuguese Accept-Language" do
      assert Locale.determine_locale(nil, "pt-BR,pt;q=0.9") == "pt_BR"
    end

    test "defaults to pt_BR without a session locale or a header" do
      assert Locale.determine_locale(nil, nil) == "pt_BR"
    end

    test "ignores an unsupported session locale and defaults" do
      assert Locale.determine_locale("fr", nil) == "pt_BR"
    end

    test "ignores an unsupported session locale but still honours an English header" do
      assert Locale.determine_locale("fr", "en-GB") == "en"
    end
  end

  describe "supported?/1" do
    test "accepts Brazilian Portuguese" do
      assert Locale.supported?("pt_BR")
    end

    test "accepts English" do
      assert Locale.supported?("en")
    end

    test "rejects bare pt and other unshipped locales" do
      refute Locale.supported?("pt")
    end
  end

  test "default/0 is Brazilian Portuguese" do
    assert Locale.default() == "pt_BR"
  end
end
