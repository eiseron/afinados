defmodule Afinados.Repo.Migrations.ScopeCatalogByManufacturer do
  use Ecto.Migration

  def change do
    alter table(:needles) do
      add :series, :string
    end
  end
end
