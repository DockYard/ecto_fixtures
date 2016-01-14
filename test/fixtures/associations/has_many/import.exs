owners model: Owner, repo: Base do
  brian do
    name "Brian"
    cars [fixtures("associations/has_many/import_dep").cars.nissan, fixtures("associations/has_many/import_dep").cars.tesla]
  end
end
