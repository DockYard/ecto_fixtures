properties model: Property, repo: BaseRepo do
  one do
    owner fixtures("dag/deep/users").users.owner
    renter fixtures("dag/deep/users").users.renter
  end

  two do
    owner fixtures("dag/deep/users").users.owner2
    renter fixtures("dag/deep/users").users.renter2
  end
end
