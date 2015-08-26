owners model: Owner, repo: Base do
  brian do
    name "Brian"
    cars [cars.nissan, cars.tesla]
  end
end

cars model: Car, repo: Base do
  nissan do
    name "Nissan"
  end
  tesla do
    name "Tesla"
  end
end
