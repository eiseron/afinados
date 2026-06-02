defmodule Afinados.Identity.User do
  @moduledoc "Owner of the work: a guest (no credentials) or a member (email + password)."

  use Ecto.Schema

  schema "users" do
    field :type, :string
    field :email, :string
    field :password_hash, :string

    timestamps()
  end

  @type t :: %__MODULE__{}
end
