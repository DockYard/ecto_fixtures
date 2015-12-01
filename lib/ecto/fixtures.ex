defmodule EctoFixtures do
  def read(path), do: File.read!(path)
  def parse(content), do: EctoFixtures.Parser.parse(content)
  def condition(data), do: EctoFixtures.Conditioner.condition(data)
  def insert(data, can_insert), do: EctoFixtures.Insertion.insert(data, can_insert)
  def normalize(data), do: EctoFixtures.Normalizer.normalize(data)
  def override(data, override_data), do: EctoFixtures.Overrider.override(data, override_data)

  def fixtures(name) do
    fixtures(name, insert: true)
  end

  def fixtures(name, %{}=override) do
    fixtures(name, insert: true, override: override)
  end

  def fixtures(name, opts) do
    read("test/fixtures/#{name}.exs")
    |> parse
    |> condition
    |> override(opts[:override])
    |> insert(opts[:insert])
    |> normalize
  end
end
