defmodule AfinadosWeb.RobotsController do
  use AfinadosWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, build_robots(AfinadosWeb.Endpoint.url()))
  end

  def build_robots(base) do
    """
    User-agent: *
    Allow: /
    Disallow: /dev/

    Sitemap: #{base}/sitemap.xml
    """
  end
end
