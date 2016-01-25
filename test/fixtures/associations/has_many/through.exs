posts model: Post, repo: BaseRepo do
  foo do
    title "Test Title"
    tags [tags.bar, tags.baz]
  end
end

tags model: Tag, repo: BaseRepo do
  bar do
    name "Bar Tag"
  end

  baz do
    name "Baz Tag"
  end
end
