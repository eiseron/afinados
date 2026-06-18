defmodule AfinadosWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :afinados

  @session_options [
    store: :cookie,
    key: "_afinados_key",
    signing_salt: "E6cHh0FK",
    same_site: "Lax",
    max_age: 60 * 60 * 24 * 365,
    secure: true
  ]

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]
  )

  plug(Plug.Static,
    at: "/",
    from: :afinados,
    gzip: not code_reloading?,
    only: AfinadosWeb.static_paths(),
    raise_on_missing_only: code_reloading?
  )

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :afinados)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(AfinadosWeb.Router)
end
