import Config

config :sentry, Eiseron.ErrorMonitoring.config()

observability = [
  service: :afinados,
  env: config_env(),
  version: to_string(Application.spec(:afinados, :vsn) || "0.0.0"),
  otlp_endpoint: System.get_env("OBSERVABILITY_OTLP_ENDPOINT"),
  phoenix: [adapter: :bandit],
  ecto: [[:afinados, :repo]]
]

config :afinados, :observability, observability

for {otel_app, otel_config} <- Eiseron.Observability.config(observability) do
  config otel_app, otel_config
end

if System.get_env("PHX_SERVER") do
  config :afinados, AfinadosWeb.Endpoint, server: true
end

config :afinados, AfinadosWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

config :afinados, :docs, host: System.get_env("DOCS_URL") || "https://afinados.io"

if config_env() in [:prod, :preview] do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :afinados, Afinados.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"

  config :afinados, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :afinados, AfinadosWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  config :sentry,
         Eiseron.ErrorMonitoring.runtime_config(
           dsn: System.get_env("ERROR_MONITORING_DSN"),
           environment: config_env(),
           release: to_string(Application.spec(:afinados, :vsn))
         )

  admin_audiences =
    "ADMIN_ACCESS_AUDIENCES" |> System.get_env("") |> String.split(",", trim: true)

  config :afinados, AfinadosWeb.AdminAccessPlug,
    enabled: config_env() == :prod,
    audiences: admin_audiences,
    issuer: System.get_env("ADMIN_ACCESS_ISSUER"),
    certs_url: System.get_env("ADMIN_ACCESS_CERTS_URL")

  config :afinados, Afinados.Media.R2,
    bucket: System.get_env("MEDIA_R2_BUCKET"),
    endpoint: System.get_env("MEDIA_R2_ENDPOINT"),
    access_key_id: System.get_env("MEDIA_R2_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("MEDIA_R2_SECRET_ACCESS_KEY"),
    public_base_url: System.get_env("MEDIA_PUBLIC_BASE_URL")
end
