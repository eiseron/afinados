import Config
config :afinados, AfinadosWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :afinados, AfinadosWeb.Endpoint,
  static_url: [host: "cdn.afinados.io", scheme: "https", port: 443]

config :afinados, AfinadosWeb.Endpoint,
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: [
      hosts: ["localhost", "127.0.0.1"],
      paths: ["/up"]
    ]
  ]

config :swoosh, api_client: Swoosh.ApiClient.Req
config :swoosh, local: false
config :logger, level: :info

config :afinados, Afinados.Media, adapter: Afinados.Media.R2
