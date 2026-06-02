defmodule Afinados.Repo.Migrations.CreateCatalog do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", "DROP EXTENSION IF EXISTS citext"

    create table(:needles) do
      add :part_number, :citext, null: false
      add :manufacturer, :string, null: false
      add :total_length_tenths_mm, :integer, null: false
      add :taper_points_tenths_mm, {:array, :integer}, null: false
      add :station_diameters_um, {:array, :integer}, null: false
      add :num_clips, :integer, null: false
      timestamps()
    end

    create unique_index(:needles, :part_number)

    create table(:needle_jets) do
      add :code, :citext, null: false
      add :manufacturer, :string, null: false
      add :bore_um, :integer, null: false
      timestamps()
    end

    create unique_index(:needle_jets, :code)
  end
end
