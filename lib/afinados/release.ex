defmodule Afinados.Release do
  @moduledoc false
  @app :afinados
  @seed_profiles ~w(prod preview dev)

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed(profile \\ "prod") when is_binary(profile) do
    unless profile in @seed_profiles do
      raise ArgumentError, "unknown seed profile: #{profile}"
    end

    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo -> Afinados.Seeds.run(profile) end)
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
