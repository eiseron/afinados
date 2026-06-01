defmodule Afinados.Repo do
  use Ecto.Repo,
    otp_app: :afinados,
    adapter: Ecto.Adapters.Postgres
end
