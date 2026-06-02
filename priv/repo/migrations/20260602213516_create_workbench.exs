defmodule Afinados.Repo.Migrations.CreateWorkbench do
  use Ecto.Migration

  def change do
    create table(:carburetors) do
      add :garage_id, references(:garages, on_delete: :delete_all), null: false
      add :manufacturer, :string, null: false
      add :venturi_mm, :integer, null: false
      add :model_ref, :string
      add :label, :string

      timestamps()
    end

    create index(:carburetors, :garage_id)
    create constraint(:carburetors, :venturi_mm_positive, check: "venturi_mm > 0")

    create table(:setups) do
      add :garage_id, references(:garages, on_delete: :delete_all), null: false
      add :carburetor_id, references(:carburetors, on_delete: :delete_all), null: false
      add :label, :string

      add :needle_part_number, references(:needles, column: :part_number, type: :citext),
        null: false

      add :clip_position, :integer, null: false
      add :shim_hundredths, :integer, null: false, default: 0
      add :needle_jet_code, references(:needle_jets, column: :code, type: :citext), null: false

      timestamps()
    end

    create index(:setups, :garage_id)
    create index(:setups, :carburetor_id)
    create constraint(:setups, :clip_position_positive, check: "clip_position >= 1")
    create constraint(:setups, :shim_hundredths_non_negative, check: "shim_hundredths >= 0")
  end
end
