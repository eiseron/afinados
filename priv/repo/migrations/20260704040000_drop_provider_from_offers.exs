defmodule Afinados.Repo.Migrations.DropProviderFromOffers do
  use Ecto.Migration

  def up do
    alter table(:offers) do
      remove :provider
    end
  end

  def down do
    alter table(:offers) do
      add :provider, :string, null: false, default: "hotmart"
    end
  end
end
