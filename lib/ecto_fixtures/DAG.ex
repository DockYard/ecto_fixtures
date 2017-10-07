defmodule EctoFixtures.Dag do
  def add_edge(acc, left_row_name, right_row_name) do
    :digraph.add_edge(acc[:__dag__], left_row_name, right_row_name)

    acc
  end

  def add_vertex(acc, row_name) do
    :digraph.add_vertex(acc[:__dag__], row_name)

    acc
  end

  def create() do
    :digraph.new([:acyclic])
  end
end
