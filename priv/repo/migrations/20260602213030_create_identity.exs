defmodule Afinados.Repo.Migrations.CreateIdentity do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :type, :string, null: false
      add :email, :citext
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, :email)
    create constraint(:users, :type_guest_or_member, check: "type in ('guest', 'member')")

    create constraint(:users, :member_requires_credentials,
             check:
               "(type = 'guest' and email is null and password_hash is null) or (type = 'member' and email is not null and password_hash is not null)"
           )

    create table(:sessions) do
      add :token_hash, :binary, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :last_seen_at, :utc_datetime

      timestamps(updated_at: false)
    end

    create unique_index(:sessions, :token_hash)
    create index(:sessions, :user_id)
  end
end
