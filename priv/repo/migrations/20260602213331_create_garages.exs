defmodule Afinados.Repo.Migrations.CreateGarages do
  use Ecto.Migration

  def change do
    create table(:garages) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :label, :string

      timestamps()
    end

    create unique_index(:garages, :user_id)
  end
end
