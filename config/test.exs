import Config

config :afinados, Afinados.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASS", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database:
    "#{System.get_env("DB_NAME", "afinados")}_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :afinados, AfinadosWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "wkz2KW32yNwmPL+jj4rbPF1DakEQl3TR700AWJ7XEYZBXfE8vQS4KpqS2JtYmJqZ",
  server: false

config :afinados, Afinados.Mailer, adapter: Swoosh.Adapters.Test
config :swoosh, :api_client, false
config :sentry, dsn: nil
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix,
  sort_verified_routes_query_params: true
