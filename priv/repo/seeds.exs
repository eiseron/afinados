alias Afinados.Carburetion.Catalog
alias Afinados.Repo

needles = [
  %{
    part_number: "4D3",
    manufacturer: "mikuni",
    total_length_tenths_mm: 503,
    taper_points_tenths_mm: [253],
    station_diameters_um: [2511, 2511, 2421, 2253, 2100],
    num_clips: 5
  }
]

needle_jets = [
  %{code: "159-P4", manufacturer: "mikuni", bore_um: 2700}
]

for attrs <- needles do
  %Catalog.Needle{}
  |> Catalog.Needle.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :part_number)
end

for attrs <- needle_jets do
  %Catalog.NeedleJet{}
  |> Catalog.NeedleJet.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :code)
end
