defmodule Afinados.ObservabilityTest do
  use ExUnit.Case, async: true

  defp opts, do: Application.get_env(:afinados, :observability)

  test "the runtime identifies the service as afinados" do
    assert opts()[:service] == :afinados
  end

  test "the runtime instruments phoenix through the bandit adapter" do
    assert opts()[:phoenix] == [adapter: :bandit]
  end

  test "the runtime instruments the afinados repo for ecto traces" do
    assert opts()[:ecto] == [[:afinados, :repo]]
  end

  test "export stays disabled until an OTLP endpoint is provided at deploy time" do
    refute Eiseron.Observability.export?(opts())
  end
end
