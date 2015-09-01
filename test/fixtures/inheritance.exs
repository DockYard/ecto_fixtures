owners model: Owner, repo: BaseRepo do
  brian do
    name "Brian"
    admin false
    template %Owner{}
    viewed_profile true
  end

  stephanie inherits: brian do
    name "Stephanie"
  end
end

other_owners model: Owner, repo: BaseRepo do
  thomas inherits: owners.brian do
    name "Thomas"
    admin true
  end
end
