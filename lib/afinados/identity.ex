defmodule Afinados.Identity do
  @moduledoc "Guest-first identity: a random token maps a browser to a User (guest now, member after login)."

  import Ecto.Query

  alias Afinados.Identity.{Session, User}
  alias Afinados.Repo

  @rand_size 32

  @spec generate_token() :: binary()
  def generate_token, do: Base.url_encode64(:crypto.strong_rand_bytes(@rand_size), padding: false)

  @spec hash_token(binary()) :: binary()
  def hash_token(token), do: :crypto.hash(:sha256, token)

  @spec user_for_token(binary() | nil) :: User.t() | nil
  def user_for_token(nil), do: nil

  def user_for_token(token) do
    hash = hash_token(token)

    Repo.one(
      from s in Session, where: s.token_hash == ^hash, join: u in assoc(s, :user), select: u
    )
  end

  @spec ensure_user_for_token(binary()) :: User.t()
  def ensure_user_for_token(token) do
    case user_for_token(token) do
      nil -> create_guest_with_session(token)
      user -> user
    end
  end

  defp create_guest_with_session(token) do
    user = Repo.insert!(%User{type: "guest"})
    now = DateTime.truncate(DateTime.utc_now(), :second)
    Repo.insert!(%Session{token_hash: hash_token(token), user_id: user.id, last_seen_at: now})
    user
  end
end
