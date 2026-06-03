alias Afinados.Carburetion.Catalog
alias Afinados.Carburetion.Catalog.Mikuni
alias Afinados.Repo

for attrs <- Mikuni.needles() do
  %Catalog.Needle{}
  |> Catalog.Needle.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :part_number)
end

for attrs <- Mikuni.needle_jets() do
  %Catalog.NeedleJet{}
  |> Catalog.NeedleJet.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :code)
end
