posts model: Post, repo: BaseRepo do
  foo do
    title "Test Title"
    tag tags.bar
  end
end

tags model: Tag, repo: BaseRepo do
  bar do
    name "Test Tag"
  end
end
