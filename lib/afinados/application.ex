defmodule Afinados.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Eiseron.ErrorMonitoring.attach()

    observability = Application.get_env(:afinados, :observability, [])

    children = [
      AfinadosWeb.Telemetry,
      Afinados.Repo,
      {DNSCluster, query: Application.get_env(:afinados, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Afinados.PubSub},
      {Eiseron.Observability.Supervisor, observability},
      AfinadosWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Afinados.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      Eiseron.Observability.setup(observability)
      {:ok, pid}
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    AfinadosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
