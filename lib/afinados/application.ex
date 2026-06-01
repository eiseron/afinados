defmodule Afinados.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AfinadosWeb.Telemetry,
      Afinados.Repo,
      {DNSCluster, query: Application.get_env(:afinados, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Afinados.PubSub},
      AfinadosWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Afinados.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AfinadosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
