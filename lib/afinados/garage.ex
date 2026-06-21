defmodule Afinados.Garage do
  @moduledoc "Tenant: a project owned by a User; groups the carburetion work (carburetors/setups/calculations)."

  use Ecto.Schema

  import Ecto.Query

  alias Afinados.Identity.User
  alias Afinados.Repo

  schema "garages" do
    field :label, :string
    belongs_to :user, User

    timestamps()
  end

  @type t :: %__MODULE__{}

  @spec default_for(User.t()) :: t()
  def default_for(%User{id: user_id}) do
    Repo.insert!(%__MODULE__{user_id: user_id},
      on_conflict: :nothing,
      conflict_target: :user_id
    )

    Repo.one!(from g in __MODULE__, where: g.user_id == ^user_id)
  end

  @spec list_for(User.t()) :: [t()]
  def list_for(%User{id: user_id}) do
    Repo.all(from g in __MODULE__, where: g.user_id == ^user_id, order_by: g.id)
  end
end
