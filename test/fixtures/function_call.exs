owners model: Owner, repo: BaseRepo do
  brian do
    password_hash :crypto.hash(:sha, "password")
  end
end
