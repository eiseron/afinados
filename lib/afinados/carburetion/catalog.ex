defmodule Afinados.Carburetion.Catalog do
  @moduledoc "Read access to the seeded catalog; resolves records into pure carburetion value objects (mm)."

  import Ecto.Query

  alias Afinados.Carburetion.Catalog.Needle, as: NeedleRecord
  alias Afinados.Carburetion.Catalog.NeedleJet, as: NeedleJetRecord
  alias Afinados.Carburetion.{Needle, NeedleJet}
  alias Afinados.Repo

  @spec list_needles() :: [NeedleRecord.t()]
  def list_needles, do: Repo.all(from n in NeedleRecord, order_by: n.part_number)

  @spec list_needle_jets() :: [NeedleJetRecord.t()]
  def list_needle_jets, do: Repo.all(from j in NeedleJetRecord, order_by: j.code)

  @spec fetch_needle(String.t()) :: {:ok, Needle.t()} | :error
  def fetch_needle(part_number) do
    case Repo.get_by(NeedleRecord, part_number: part_number) do
      nil -> :error
      record -> {:ok, build_needle(record)}
    end
  end

  @spec fetch_needle_jet(String.t()) :: {:ok, NeedleJet.t()} | :error
  def fetch_needle_jet(code) do
    case Repo.get_by(NeedleJetRecord, code: code) do
      nil -> :error
      record -> {:ok, build_needle_jet(record)}
    end
  end

  @spec build_needle(NeedleRecord.t()) :: Needle.t()
  def build_needle(%NeedleRecord{} = record) do
    %Needle{
      part_number: record.part_number,
      total_length_mm: record.total_length_tenths_mm / 10,
      taper_points_mm: Enum.map(record.taper_points_tenths_mm, &(&1 / 10)),
      station_diameters_mm: Enum.map(record.station_diameters_um, &(&1 / 1000)),
      num_clips: record.num_clips
    }
  end

  @spec build_needle_jet(NeedleJetRecord.t()) :: NeedleJet.t()
  def build_needle_jet(%NeedleJetRecord{} = record) do
    %NeedleJet{code: record.code, bore_mm: record.bore_um / 1000}
  end
end
