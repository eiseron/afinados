import Config

config :afinados,
  ecto_repos: [Afinados.Repo],
  generators: [timestamp_type: :utc_datetime]

config :gettext, :default_locale, "pt_BR"

config :afinados, AfinadosWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AfinadosWeb.ErrorHTML, json: AfinadosWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Afinados.PubSub,
  live_view: [signing_salt: "RgVxCEmn"]

config :afinados, Afinados.Mailer, adapter: Swoosh.Adapters.Local

config :esbuild,
  version: "0.25.4",
  afinados: [
    args:
      ~w(js/app.js css/app.css --bundle --target=es2022 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
