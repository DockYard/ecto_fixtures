pets model: Pet, repo: Base do
  boomer do
    name "Boomer"
    owner fixtures("associations/belongs_to/import_dep").owners.brian
  end
end
