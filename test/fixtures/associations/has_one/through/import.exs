posts model: Post, repo: BaseRepo do
  foo do
    title "Test Title"
    tag fixtures("associations/has_one/through/import_dep").tags.bar
  end
end
