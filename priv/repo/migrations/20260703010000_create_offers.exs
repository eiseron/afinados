defmodule Afinados.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :provider, :string, null: false
      add :kind, :string, null: false
      add :locale, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :image_url, :string
      add :target_url, :string, null: false
      add :context_tags, {:array, :string}, null: false, default: []
      add :surfaces, {:array, :string}, null: false, default: []
      add :position, :integer, null: false, default: 0
      add :active, :boolean, null: false, default: true

      timestamps()
    end

    create constraint(:offers, :provider_known, check: "provider in ('hotmart', 'aliexpress')")
    create constraint(:offers, :kind_known, check: "kind in ('course', 'part')")
    create constraint(:offers, :position_non_negative, check: "position >= 0")
    create index(:offers, [:locale, :active])
  end
end
