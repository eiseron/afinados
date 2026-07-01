defmodule AfinadosWeb.SitemapController do
  use AfinadosWeb, :controller

  @public_paths AfinadosWeb.Router.__routes__()
                |> Enum.filter(&(&1.verb == :get and &1.plug == Phoenix.LiveView.Plug))
                |> Enum.map(& &1.path)
                |> Enum.reject(&(String.contains?(&1, ":") or String.starts_with?(&1, "/dev")))
                |> Enum.uniq()
                |> Enum.sort()

  def index(conn, _params) do
    sitemap = build_sitemap(AfinadosWeb.Endpoint.url(), @public_paths)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, sitemap)
  end

  def build_sitemap(base, paths) do
    entries = Enum.map_join(paths, &build_url_entry(base, &1))

    ~s(<?xml version="1.0" encoding="UTF-8"?>) <>
      ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">) <>
      entries <>
      ~s(</urlset>)
  end

  defp build_url_entry(base, path) do
    "<url><loc>#{escape_xml(base <> path)}</loc></url>"
  end

  defp escape_xml(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
