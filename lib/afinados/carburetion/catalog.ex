defmodule Afinados.Carburetion.Catalog do
  @moduledoc "Read access to the seeded catalog; resolves records into pure carburetion value objects (mm)."

  import Ecto.Query

  alias Afinados.Carburetion.Catalog.Needle, as: NeedleRecord
  alias Afinados.Carburetion.Catalog.NeedleJet, as: NeedleJetRecord
  alias Afinados.Carburetion.{Needle, NeedleJet}
  alias Afinados.Repo

  @spec list_manufacturers() :: [String.t()]
  def list_manufacturers do
    Repo.all(
      from n in NeedleRecord, distinct: true, select: n.manufacturer, order_by: n.manufacturer
    )
  end

  @spec list_needles(String.t()) :: [NeedleRecord.t()]
  def list_needles(manufacturer), do: list_needles(manufacturer, nil)

  @spec list_needles(String.t(), String.t() | nil) :: [NeedleRecord.t()]
  def list_needles(manufacturer, nil) do
    Repo.all(
      from n in NeedleRecord, where: n.manufacturer == ^manufacturer, order_by: n.part_number
    )
  end

  def list_needles(manufacturer, series) do
    Repo.all(
      from n in NeedleRecord,
        where: n.manufacturer == ^manufacturer and n.series == ^series,
        order_by: n.part_number
    )
  end

  @spec list_needle_jets(String.t()) :: [NeedleJetRecord.t()]
  def list_needle_jets(manufacturer) do
    Repo.all(from j in NeedleJetRecord, where: j.manufacturer == ^manufacturer, order_by: j.code)
  end

  @spec fetch_needle(String.t() | nil, String.t() | nil) :: {:ok, Needle.t()} | :error
  def fetch_needle(_manufacturer, nil), do: :error
  def fetch_needle(nil, _part_number), do: :error

  def fetch_needle(manufacturer, part_number) do
    case Repo.get_by(NeedleRecord, manufacturer: manufacturer, part_number: part_number) do
      nil -> :error
      record -> {:ok, build_needle(record)}
    end
  end

  @spec fetch_needle_jet(String.t() | nil, String.t() | nil) :: {:ok, NeedleJet.t()} | :error
  def fetch_needle_jet(_manufacturer, nil), do: :error
  def fetch_needle_jet(nil, _code), do: :error

  def fetch_needle_jet(manufacturer, code) do
    case Repo.get_by(NeedleJetRecord, manufacturer: manufacturer, code: code) do
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
