invoices model: Invoice, repo: BaseRepo do
  one do
    property fixtures("dag/deep/properties").properties.one
    owner fixtures("dag/deep/users").users.owner
    renter fixtures("dag/deep/users").users.renter
  end
end
