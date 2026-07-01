defmodule AfinadosWeb.SeoLayoutTest do
  use AfinadosWeb.ConnCase, async: true

  describe "root layout SEO tags" do
    test "renders a canonical link for the current path", %{conn: conn} do
      conn = get(conn, ~p"/")

      assert html_response(conn, 200) =~
               ~s(<link rel="canonical" href="#{AfinadosWeb.Endpoint.url()}/">)
    end

    test "declares the html lang from the active locale", %{conn: conn} do
      conn = get(conn, ~p"/")

      assert html_response(conn, 200) =~ ~s(<html lang="pt-BR">)
    end

    test "sets the canonical to the current path, not the home", %{conn: conn} do
      conn = get(conn, ~p"/carburetion/intake-sizing")

      assert html_response(conn, 200) =~
               ~s(<link rel="canonical" href="#{AfinadosWeb.Endpoint.url()}/carburetion/intake-sizing">)
    end
  end

  describe "html_lang/0" do
    test "maps the default gettext locale to a BCP47 tag" do
      assert AfinadosWeb.Layouts.html_lang() == "pt-BR"
    end

    test "reflects the active locale instead of a fixed value" do
      Gettext.put_locale(AfinadosWeb.Gettext, "en")

      assert AfinadosWeb.Layouts.html_lang() == "en"
    end
  end
end
