owners model: Owner, repo: Base do
  brian do
    name "Brian"
  end
end

pets model: Pet, repo: Base do
  boomer do
    name "Boomer"
    owner owners.brian
  end
end
