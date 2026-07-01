defmodule AfinadosWeb.SitemapControllerTest do
  use AfinadosWeb.ConnCase, async: true

  alias AfinadosWeb.SitemapController

  describe "GET /sitemap.xml" do
    setup %{conn: conn} do
      %{conn: get(conn, ~p"/sitemap.xml"), base: AfinadosWeb.Endpoint.url()}
    end

    test "responds as an XML sitemap", %{conn: conn} do
      assert response_content_type(conn, :xml) =~ "application/xml"

      body = response(conn, 200)
      assert body =~ ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">)
    end

    test "lists the public pages as absolute URLs", %{conn: conn, base: base} do
      body = response(conn, 200)

      assert body =~ "<loc>#{base}/</loc>"
      assert body =~ "<loc>#{base}/carburetion/setups</loc>"
      assert body =~ "<loc>#{base}/carburetion/intake-sizing</loc>"
    end

    test "omits parameterized, dev and infrastructure routes", %{conn: conn} do
      body = response(conn, 200)

      refute body =~ ":id"
      refute body =~ "/dev"
      refute body =~ "/up"
      refute body =~ "/sitemap.xml"
    end
  end

  describe "build_sitemap/2" do
    test "wraps each path as an absolute <loc> inside a urlset" do
      xml =
        SitemapController.build_sitemap("https://app.afinados.io", ["/", "/carburetion/setups"])

      assert xml ==
               ~s(<?xml version="1.0" encoding="UTF-8"?>) <>
                 ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">) <>
                 ~s(<url><loc>https://app.afinados.io/</loc></url>) <>
                 ~s(<url><loc>https://app.afinados.io/carburetion/setups</loc></url>) <>
                 ~s(</urlset>)
    end

    test "escapes XML-reserved characters in URLs" do
      xml = SitemapController.build_sitemap("https://app.afinados.io", ["/a?x=1&y=2"])

      assert xml =~ "<loc>https://app.afinados.io/a?x=1&amp;y=2</loc>"
    end
  end
end
