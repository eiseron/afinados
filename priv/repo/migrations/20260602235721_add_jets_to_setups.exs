defmodule Afinados.Repo.Migrations.AddJetsToSetups do
  use Ecto.Migration

  def change do
    alter table(:setups) do
      add :high_jet_number, :integer, null: false
      add :low_jet_number, :float, null: false
    end

    create constraint(:setups, :high_jet_number_positive, check: "high_jet_number > 0")
    create constraint(:setups, :low_jet_number_positive, check: "low_jet_number > 0")
  end
end
