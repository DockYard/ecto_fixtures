defmodule EctoFixtures.Conditioners.DAG do
  def process(data, path) do
    add_vertex(data, path, get_in(data, [:__DAG__]))
  end

  def add_edge(data, left, right) do
    :digraph.add_edge(get_in(data, [:__DAG__]), left, right)
    data
  end

  def add_vertex(data, path, nil) do
    data = create_dag(data, path)
    add_vertex(data, path, get_in(data, [:__DAG__]))
  end

  def add_vertex(data, path, dag) do
    :digraph.add_vertex(dag, path)
    data
  end

  defp create_dag(data, path) do
    Map.put(data, :__DAG__, :digraph.new([:acyclic]))
  end
end
