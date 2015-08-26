defmodule Fixtures do
  def parse(content), do: Fixtures.Parser.parse(content)
  def condition(data), do: Fixtures.Conditioner.condition(data)
  def read(path), do: File.read!(path) |> parse
end
