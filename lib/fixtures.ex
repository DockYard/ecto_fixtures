defmodule Fixtures do
  def parse(path), do: Fixtures.Parser.parse(path)
  def condition(data), do: Fixtures.Conditioner.condition(data)
end
