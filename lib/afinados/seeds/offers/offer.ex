defmodule Afinados.Seeds.Offers.Offer do
  @moduledoc "Example affiliate offers for non-production environments; production offers are curated via the admin."

  alias Afinados.Offers.Offer
  alias Afinados.Repo

  @offers [
    %{
      provider: "hotmart",
      kind: "course",
      locale: "pt_BR",
      title: "Curso de preparação de motores 2 tempos",
      description: "Fundamentos de carburação e afinação para motores dois tempos.",
      target_url: "https://go.hotmart.com/example-2t-pt",
      context_tags: ["carburation", "two_stroke"],
      surfaces: ["hub_shelf"],
      position: 0
    },
    %{
      provider: "aliexpress",
      kind: "part",
      locale: "pt_BR",
      title: "Carburador Nibbi PE28",
      description: "Carburador de alta performance para motores de pequena cilindrada.",
      target_url: "https://s.click.aliexpress.com/example-nibbi",
      context_tags: ["nibbi", "carburetor"],
      surfaces: ["hub_shelf", "jet_suggestion"],
      position: 1
    },
    %{
      provider: "hotmart",
      kind: "course",
      locale: "en",
      title: "Two-stroke engine tuning course",
      description: "Carburetion and jetting fundamentals for two-stroke engines.",
      target_url: "https://go.hotmart.com/example-2t-en",
      context_tags: ["carburation", "two_stroke"],
      surfaces: ["hub_shelf"],
      position: 0
    }
  ]

  @spec data() :: [map()]
  def data, do: @offers

  @spec seed() :: :ok
  def seed do
    Enum.each(@offers, fn attrs ->
      %Offer{} |> Offer.changeset(attrs) |> Repo.insert!()
    end)
  end
end
