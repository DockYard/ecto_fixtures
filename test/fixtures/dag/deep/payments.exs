payments model: Payment, repo: BaseRepo do
  one do
    invoice fixtures("dag/deep/invoices").invoices.one
    payee fixtures("dag/deep/users").users.owner
    payer fixtures("dag/deep/users").users.renter
  end
end
