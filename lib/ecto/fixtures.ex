defmodule EctoFixtures do
  def read(path), do: File.read!(path)
  def parse(content), do: EctoFixtures.Parser.parse(content)
  def condition(data), do: EctoFixtures.Conditioner.condition(data)
  def insert(data, can_insert), do: EctoFixtures.Insertion.insert(data, can_insert)
  def normalize(data), do: EctoFixtures.Normalizer.normalize(data)

  def fixtures(name) do
    fixtures(name, insert: true)
  end

  def fixtures(name, [insert: can_insert]) do
    read("test/fixtures/#{name}.exs")
    |> parse
    |> condition
    |> insert(can_insert)
    |> normalize
  end
end
