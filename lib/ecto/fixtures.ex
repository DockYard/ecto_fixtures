defmodule EctoFixtures do
  def read(file_path), do: {String.to_atom(file_path), File.read!(file_path)}
  def parse(content), do: EctoFixtures.Parser.process(content)
  def condition(data, opts \\ []), do: EctoFixtures.Conditioner.process(data, opts)
  def insert(data, can_insert), do: EctoFixtures.Insertion.process(data, can_insert)
  def normalize(data), do: EctoFixtures.Normalizer.process(data)

  def fixtures(name) do
    fixtures(name, insert: true)
  end

  def fixtures(name, %{}=override) do
    fixtures(name, insert: true, override: override)
  end

  def fixtures(name, opts) do
    source = "test/fixtures/#{name}.exs"

    read(source)
    |> parse
    |> condition(source: String.to_atom(source), override: opts[:override])
    |> insert(opts[:insert])
  end
end
