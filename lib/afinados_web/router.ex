defmodule AfinadosWeb.Router do
  use AfinadosWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(AfinadosWeb.Locale)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {AfinadosWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'"})
    plug(:put_csp_nonce)
    plug(:put_canonical_url)
    plug(AfinadosWeb.GuestToken)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin do
    plug(AfinadosWeb.AdminAccessPlug)
  end

  defp put_csp_nonce(conn, _opts) do
    nonce = 16 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

    conn
    |> Plug.Conn.assign(:csp_nonce, nonce)
    |> Plug.Conn.put_resp_header("content-security-policy", content_security_policy(nonce))
  end

  defp put_canonical_url(conn, _opts) do
    Plug.Conn.assign(conn, :canonical_url, AfinadosWeb.Endpoint.url() <> conn.request_path)
  end

  defp content_security_policy(nonce) do
    static = AfinadosWeb.Endpoint.static_url()

    Enum.join(
      [
        "default-src 'self'",
        "script-src 'self' 'nonce-#{nonce}' #{static}",
        "style-src 'self' #{static}",
        "img-src 'self' #{static}",
        "font-src 'self' #{static}"
      ],
      "; "
    )
  end

  scope "/", AfinadosWeb do
    get("/up", HealthController, :index)
    get("/sitemap.xml", SitemapController, :index)
    get("/robots.txt", RobotsController, :index)
  end

  scope "/", AfinadosWeb do
    pipe_through(:browser)

    post("/locale/:locale", LocaleController, :update)

    live_session :default, on_mount: [AfinadosWeb.RestoreLocale] do
      live("/", HubLive)
      live("/carburetion/setups", SetupLive)
      live("/carburetion/setups/:id", SetupLive)
      live("/carburetion/intake-sizing", IntakeSizingLive)
    end
  end

  scope "/admin", AfinadosWeb.Admin do
    pipe_through([:browser, :admin])

    live_session :admin, on_mount: [AfinadosWeb.RestoreLocale, AfinadosWeb.Admin.RequireAdmin] do
      live("/", HomeLive)
    end
  end

  if Application.compile_env(:afinados, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: AfinadosWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
