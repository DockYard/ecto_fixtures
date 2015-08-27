owners model: Owner, repo: BaseRepo do
  brian do
    password_hash :crypto.sha("password")
  end
end
