defmodule Afinados.Seeds do
  @moduledoc false
  alias Afinados.Seeds.Carburetion.KeihinNeedle
  alias Afinados.Seeds.Carburetion.KeihinNeedleJet
  alias Afinados.Seeds.Carburetion.Needle
  alias Afinados.Seeds.Carburetion.NeedleJet

  @spec run(String.t()) :: :ok
  def run(profile) do
    seed_reference_data()
    seed_environment_fixtures(profile)
  end

  defp seed_reference_data do
    Needle.seed()
    NeedleJet.seed()
    KeihinNeedle.seed()
    KeihinNeedleJet.seed()
    :ok
  end

  defp seed_environment_fixtures("prod"), do: :ok
  defp seed_environment_fixtures("preview"), do: :ok
  defp seed_environment_fixtures("dev"), do: :ok
end
