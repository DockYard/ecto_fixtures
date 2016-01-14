owners model: Owner, repo: BaseRepo do
  non_admin inherits: fixtures(:inheritance).other_owners.thomas do
    admin false
  end
end
