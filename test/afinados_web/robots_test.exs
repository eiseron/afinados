defmodule AfinadosWeb.RobotsTest do
  use AfinadosWeb.ConnCase, async: true

  alias AfinadosWeb.RobotsController

  describe "GET /robots.txt" do
    setup %{conn: conn} do
      %{conn: get(conn, ~p"/robots.txt")}
    end

    test "is served as text/plain", %{conn: conn} do
      assert response_content_type(conn, :txt) =~ "text/plain"
    end

    test "allows crawling and points to the sitemap on the same host", %{conn: conn} do
      body = response(conn, 200)
      base = AfinadosWeb.Endpoint.url()

      assert body =~ "User-agent: *"
      assert body =~ "Allow: /"
      assert body =~ "Disallow: /dev/"
      assert body =~ "Sitemap: #{base}/sitemap.xml"
    end
  end

  describe "build_robots/1" do
    test "derives the sitemap URL from the given base" do
      assert RobotsController.build_robots("https://app.afinados.io") =~
               "Sitemap: https://app.afinados.io/sitemap.xml"
    end
  end
end
