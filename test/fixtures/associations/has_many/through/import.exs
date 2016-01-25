posts model: Post, repo: BaseRepo do
  foo do
    title "Test Title"
    tags [fixtures("associations/has_many/through/import_dep").tags.bar, fixtures("associations/has_many/through/import_dep").tags.baz]
  end
end
