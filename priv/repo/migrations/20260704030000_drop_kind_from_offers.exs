defmodule Afinados.Repo.Migrations.DropKindFromOffers do
  use Ecto.Migration

  def up do
    drop constraint(:offers, :kind_known)

    alter table(:offers) do
      remove :kind
    end
  end

  def down do
    alter table(:offers) do
      add :kind, :string, null: false, default: "course"
    end

    create constraint(:offers, :kind_known, check: "kind in ('course', 'part')")
  end
end
