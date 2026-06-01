import Config

config :afinados, Afinados.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASS", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "afinados_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :afinados, AfinadosWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "gfa3AEEtwv0NtSXQiQtrXMe4gAXSrQ6CrAr9fPIxaDuVzaHtlnDVWPezGenJ5p9m",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:afinados, ~w(--sourcemap=inline --watch)]}
  ]

config :afinados, AfinadosWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"priv/gettext/.*\.po$"E,
      ~r"lib/afinados_web/router\.ex$"E,
      ~r"lib/afinados_web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

config :afinados, dev_routes: true
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

config :swoosh, :api_client, false
