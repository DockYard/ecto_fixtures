defmodule Ecto.Fixtures do
  def read(path), do: File.read!(path)
  def parse(content), do: Ecto.Fixtures.Parser.parse(content)
  def condition(data), do: Ecto.Fixtures.Conditioner.condition(data)
  def insert(data), do: Ecto.Fixtures.Insertion.insert(data)
  def normalize(data), do: Ecto.Fixtures.Normalizer.normalize(data)

  def fixtures(name) do
    data = read("test/fixtures/#{name}.exs")
    |> parse
    |> condition
    |> insert
    |> normalize
  end
end
