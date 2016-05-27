properties model: Property, repo: BaseRepo do
  one do
    owner fixtures("dag/deep/users").users.owner
    renter fixtures("dag/deep/users").users.renter
  end
end
