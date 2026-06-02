defmodule Afinados.Identity.Session do
  @moduledoc "Browser identity: maps a hashed token to the current user."

  use Ecto.Schema

  alias Afinados.Identity.User

  schema "sessions" do
    field :token_hash, :binary
    field :last_seen_at, :utc_datetime
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @type t :: %__MODULE__{}
end
