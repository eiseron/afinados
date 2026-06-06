import Config

config :afinados, AfinadosWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  debug_errors: true,
  check_origin: false

config :afinados, AfinadosWeb.Endpoint,
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: [
      hosts: ["localhost", "127.0.0.1"]
    ]
  ]

config :swoosh, api_client: Swoosh.ApiClient.Req
config :swoosh, local: false

config :logger, level: :debug
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20

config :afinados, dev_routes: true
