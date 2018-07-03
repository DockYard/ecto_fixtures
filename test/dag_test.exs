defmodule EctoFixtures.DagTest do
  use ExUnit.Case

  alias EctoFixtures.{Dag, Dag.Vertex, Dag.CycleError}

  test "a new dag struct" do
    dag = %Dag{}

    assert dag.vertices == %{}
  end

  describe "vertex functions" do
    test "adding single vertex" do
      dag = Dag.add_vertex(%Dag{}, :foobar, 1)

      %{foobar: vertex} = dag.vertices

      assert vertex.label == :foobar
      assert vertex.out_edges == []
      assert vertex.in_edges == []
      assert vertex.value == 1
    end

    test "adding a vertex with optional function will condition the value" do
      dag = Dag.add_vertex(%Dag{}, :foobar, 1, &(&1 + 1))

      %{foobar: vertex} = dag.vertices

      assert vertex.value == 2
    end

    test "raise ArgumentError if named vertex already exists when adding" do
      dag = Dag.add_vertex(%Dag{}, :foobar, 1)

      assert_raise ArgumentError, "vertex :foobar already exists in graph", fn ->
        Dag.add_vertex(dag, :foobar, 2)      
      end
    end

    test "adding many vertices" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}])

      %{foo: foo, bar: bar, baz: baz} = dag.vertices

      assert foo.value == 1
      assert bar.value == 2
      assert baz.value == 3
    end

    test "adding many vertices with optional function to condition values" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}], &(&1 * 2))

      %{foo: foo, bar: bar, baz: baz} = dag.vertices

      assert foo.value == 2
      assert bar.value == 4
      assert baz.value == 6
    end

    test "get a vertex by its label" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}])

      vertex = Dag.get_vertex(dag, :foo)

      assert vertex.label == :foo
    end

    test "fetch a vertex by its label" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}])

      {:ok, vertex} = Dag.fetch_vertex(dag, :foo)
      assert vertex.label == :foo

      :error = Dag.fetch_vertex(dag, :other)
    end

    test "get_in vertex will fetch vertex by label then return value in path" do
      dag = Dag.add_vertex(%Dag{}, :foo, %{a: %{b: 2}})
      value = Dag.get_in(dag, :foo, [:a, :b])
      assert value == 2
    end

    test "put vertext into graph" do
      dag = %Dag{}

      vertex = %Vertex{label: :foo, value: 1}
      dag = Dag.put_vertex(dag, vertex)
      %{foo: foo} = dag.vertices
      assert foo.value == 1

      vertex = %Vertex{label: :foo, value: 2}
      dag = Dag.put_vertex(dag, vertex)
      %{foo: foo} = dag.vertices
      assert foo.value == 2
    end

    test "put_in a value in a given vertex" do
      graph = Dag.add_vertex(%Dag{}, :foo, %{bar: %{baz: 1}}) |> Dag.put_in(:foo, [:bar, :baz], 2)
      assert Dag.get_in(graph, :foo, [:bar, :baz]) == 2
    end

    test "delete_in will delete a key on the value map for a vertex" do
      graph =
        %Dag{}
        |> Dag.add_vertex(:foo, %{bar: %{baz: 1}})
        |> Dag.delete_in(:foo, [:bar, :baz])

      %{foo: foo} = graph.vertices

      assert foo.value[:bar] == %{}
    end
  end

  describe "adding edges" do
    test "add edge to graph between two existing vertices" do
      dag =
        %Dag{}
        |> Dag.add_vertices([{:foo, 1}, {:bar, 2}])
        |> Dag.add_edge(:foo, :bar)

      %{foo: foo, bar: bar} = dag.vertices

      assert foo.out_edges == [:bar]
      assert bar.in_edges == [:foo]

      dag =
        dag
        |> Dag.add_vertex(:baz, 3)
        |> Dag.add_edge(:foo, :baz)

      %{foo: foo, baz: baz} = dag.vertices

      assert foo.out_edges == [:bar, :baz]
      assert baz.in_edges == [:foo]
    end

    test "do nothing if attempting to add existing edge to edges" do
      %Dag{}
      |> Dag.add_vertices([{:foo, 1}, {:bar, 2}])
      |> Dag.add_edge(:foo, :bar)
      |> Dag.add_edge(:foo, :bar)
    end

    test "raise CycleError if a cycle is detected" do
      dag =
        %Dag{}
        |> Dag.add_vertices([{:foo, 1}, {:bar, 2}])
        |> Dag.add_edge(:foo, :bar)

      assert_raise CycleError, "cycle detected: `:foo -> :foo`", fn ->
        Dag.add_edge(dag, :foo, :foo)
      end

      assert_raise CycleError, "cycle detected: `:foo -> :bar -> :foo`", fn ->
        Dag.add_edge(dag, :bar, :foo)
      end

      assert_raise CycleError, "cycle detected: `:foo -> :bar -> :baz -> :qux -> :foo`", fn ->
        dag
        |> Dag.add_vertices([{:baz, 3}, {:qux, 4}, {:quux, 5}, {:quuz, 6}, {:corge, 7}, {:grault, 8}])
        |> Dag.add_edge(:foo, :quux)
        |> Dag.add_edge(:bar, :corge)
        |> Dag.add_edge(:corge, :quuz)
        |> Dag.add_edge(:bar, :baz)
        |> Dag.add_edge(:baz, :qux)
        |> Dag.add_edge(:qux, :foo)
      end

      assert_raise CycleError, "cycle detected: `:bar -> :baz -> :qux -> :bar`", fn ->
        dag
        |> Dag.add_vertices([{:baz, 3}, {:qux, 4}, {:quux, 5}, {:quuz, 6}, {:corge, 7}, {:grault, 8}])
        |> Dag.add_edge(:foo, :quux)
        |> Dag.add_edge(:bar, :corge)
        |> Dag.add_edge(:corge, :quuz)
        |> Dag.add_edge(:bar, :baz)
        |> Dag.add_edge(:baz, :qux)
        |> Dag.add_edge(:qux, :bar)
      end
    end
  end

  describe "topological sorting" do
    test "returns sorted list" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}, {:qux, 4}, {:quux, 5}, {:quuz, 6}, {:corge, 7}, {:grault, 8}])

      sorted = Dag.topsort(dag)

      assert Enum.member?(sorted, :foo)
      assert Enum.member?(sorted, :bar)
      assert Enum.member?(sorted, :baz)
      assert Enum.member?(sorted, :qux)
      assert Enum.member?(sorted, :quux)
      assert Enum.member?(sorted, :quuz)
      assert Enum.member?(sorted, :corge)
      assert Enum.member?(sorted, :grault)
    end

    test "returns sorted list with only subset" do
      dag = Dag.add_vertices(%Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}, {:qux, 4}, {:quux, 5}, {:quuz, 6}, {:corge, 7}, {:grault, 8}])

      sorted = Dag.topsort(dag, [:foo, :baz, :quux, :corge])

      assert Enum.member?(sorted, :foo)
      refute Enum.member?(sorted, :bar)
      assert Enum.member?(sorted, :baz)
      refute Enum.member?(sorted, :qux)
      assert Enum.member?(sorted, :quux)
      refute Enum.member?(sorted, :quuz)
      assert Enum.member?(sorted, :corge)
      refute Enum.member?(sorted, :grault)
    end

    defp get_index(list, value) do
      Enum.find_index(list, &(&1 == value))
    end

    test "sorts based upon topological hierarchy" do
      dag =
        %Dag{}
        |> Dag.add_vertices([{:foo, 1}, {:bar, 2}, {:baz, 3}, {:qux, 4}, {:quux, 5}, {:quuz, 6}, {:corge, 7}, {:grault, 8}])
        |> Dag.add_edge(:foo, :bar)
        |> Dag.add_edge(:foo, :quux)
        |> Dag.add_edge(:bar, :corge)
        |> Dag.add_edge(:corge, :quuz)
        |> Dag.add_edge(:bar, :baz)
        |> Dag.add_edge(:baz, :qux)

      sorted = Dag.topsort(dag)

      assert get_index(sorted, :foo) < get_index(sorted, :bar)
      assert get_index(sorted, :foo) < get_index(sorted, :quux)
      assert get_index(sorted, :bar) < get_index(sorted, :corge)
      assert get_index(sorted, :bar) < get_index(sorted, :baz)
      assert get_index(sorted, :corge) < get_index(sorted, :quuz)
      assert get_index(sorted, :baz) < get_index(sorted, :qux)
    end
  end
end