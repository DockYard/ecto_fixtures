defmodule EctoFixtures do
  def read(path), do: File.read!(path)
  def parse(content), do: EctoFixtures.Parser.parse(content)
  def condition(data), do: EctoFixtures.Conditioner.condition(data)
  def insert(data), do: EctoFixtures.Insertion.insert(data)
  def normalize(data), do: EctoFixtures.Normalizer.normalize(data)

  def fixtures(name) do
    data = read("test/fixtures/#{name}.exs")
    |> parse
    |> condition
    |> insert
    |> normalize
  end
end
