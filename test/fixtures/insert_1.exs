cars model: Car, repo: BaseRepo do
  nissan do
    color "black"
    owner owners.brian
  end
  tesla do
    color "red"
  end
  toyota do
    color "white"
  end
end

owners model: Owner, repo: BaseRepo do
  brian do
    name "Brian"
    pet pets.boomer
  end
  stephanie do
    name "Stephanie"
    cars [cars.tesla, cars.toyota]
  end
end

pets model: Pet, repo: BaseRepo do
  boomer do
    name "Boomer"
  end
end
