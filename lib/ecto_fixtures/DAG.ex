defmodule EctoFixtures.Dag do
  @moduledoc """
  Directed Acyclic Graph for EctoFixtures

  This implementation is specific for EctoFixtures and includes some optimizations
  over Erlang's native `:digraph` library.

  Why can't we use `:digraph`? Most importantly `:digraph` writes the graph to `:ets`
  which means we cannot create the graph and save it at compile time as it would not
  be available in the future. This implementation is done entirely in Elixir types
  and this we *can* write out at compile-time. This improves the run-time performance
  of EctoFixtures because we no longer need to build a new graph on each run. While
  that time is minimal, it does accumulate.

  Another example is that the vertices can hold values. This allows us to store the
  actual repos in the DAG rather than storing the DAG in addition the records.
  """

  alias EctoFixtures.Dag.Vertex

  @type t :: %__MODULE__{vertices: map}
  defstruct vertices: %{}

  defmodule CycleError do
    defexception [:message]
  end

  @doc """
  Adds a new vertex to the graph

      graph = EctoFixtures.Dag.add_vertex(%EctoFixtures.Dag{}, :foobar, 123)

  If you attempt to overwrite an existing vertex `ArgumentError` is raised

  An alternate form takes two arguments, with the second argument being a tuple
  that consists of `{label, value}`

      graph = EctoFixtures.Dag.add_vertex(%EctoFixtures.Dag{}, {:foobar, 123})

  This other form is useful when used within an iterator.
  
  The final form can take an optional function to modify the value before prior
  to adding:
  
      graph = EctoFixtures.Dag.add_vertex(%EctoFixtures.Dag{}, :foobar, 123, &(&1 * 2))
  """
  @spec add_vertex(graph :: Dag.t, {label :: atom, value :: any}) :: Dag.t
  def add_vertex(graph, {label, value}) do
    add_vertex(graph, label, value)
  end

  @spec add_vertex(graph :: Dag.t, {label :: atom, value :: any}, fun :: function) :: Dag.t
  def add_vertex(graph, {label, value}, fun) when is_function(fun) do
    add_vertex(graph, label, value, fun)
  end

  @spec add_vertex(graph :: Dag.t, label :: atom, value :: any) :: Dag.t
  def add_vertex(graph, label, value) do
    if Map.has_key?(graph.vertices, label) do
      raise ArgumentError, "vertex #{inspect(label)} already exists in graph"
    end
    vertex = %Vertex{label: label, value: value}
    put_vertex(graph, vertex)
  end

  @spec add_vertex(graph :: Dag.t, label :: atom, value :: any, fun :: function) :: Dag.t
  def add_vertex(graph, label, value, fun) when is_function(fun) do
    add_vertex(graph, label, fun.(value))
  end

  @doc """
  Get a value from a path in a specific vertex's value

  The vertex's value must be compatible with the `Access` module.

  You can supply a vertex's label and a value path. `Kernel.get_in/2` will be used
  on that vertex's value with the given path

      path_value = Dag.get_in(graph, :foo, [:bar, :baz])
  """
  @spec get_in(graph :: Dag.t, labe :: atom, path :: list) :: any
  def get_in(graph, label, path) do
    get_vertex(graph, label).value |> get_in(path)
  end

  @doc """
  Allows you to put a value at a specific value within the given vertex's value
  
  The vertex's value must be compatible with the `Access` module.

  You can supply a vertex's label, value path, and value. `Kernel.put_in/3` will be used
  on that vertex's value with the given path

      graph = Dag.put_in(graph, :foo, [:bar, :baz], 3)
  """
  @spec put_in(graph :: Dag.t, label :: atom, path :: list, value :: any) :: Dag.t
  def put_in(graph, label, path, value) do
    vertex = get_vertex(graph, label)
    value = put_in(vertex.value, path, value)
    vertex = struct(vertex, value: value)
    put_vertex(graph, vertex)
  end

  @doc """
  Put a vertex into the graph.
  
  Will replace matching vertex by label. If you are creating a new
  vertex you will lose any previous edges. You can preserve the edges like so:

      vertex = Dag.get_vertex(graph, :foo)
      vertex = struct(vertex, value: vertex.value + 1)
      Dag.put_vertex(graph, vertex)
  """
  @spec put_vertex(graph :: Dag.t, vertex :: Vertex.t) :: Dag.t
  def put_vertex(graph, %Vertex{label: label} = vertex) do
    vertices = Map.put(graph.vertices, label, vertex)
    struct(graph, vertices: vertices)
  end

  @doc """
  Delete a key within a vertex's value map

      Dag.add_vertex(%Dag{}, :foo, %{bar: %{baz: 1}})
      |> Dag.delete_in(:foo, [:bar, :baz])
  """
  @spec delete_in(graph :: Dag.t, label :: atom, path :: list) :: Dag.t
  def delete_in(graph, label, path) do
    vertex = get_vertex(graph, label)
    {_, value} = pop_in(vertex.value, path)
    put_vertex(graph, struct(vertex, value: value))
  end

  @doc """
  Add a list of verticies to a graph. Each element in the list must be a tuple who's
  first element is the label and the second element is the value of the vertex.

      graph = EctoFixtures.Dag.add_vertex(%EctoFixtures.Dag{}, [{:foo, 1}, {:bar, 2}, {:baz, 3}])
  """
  @spec add_vertices(graph :: Dag.t, list :: list) :: Dag.t
  def add_vertices(graph, list) when is_list(list) do
    Enum.reduce(list, graph, &(add_vertex(&2, &1)))
  end

  @spec add_vertices(graph :: Dag.t, list :: list, fun :: function) :: Dag.t
  def add_vertices(graph, list, fun) when is_list(list) and is_function(fun) do
    Enum.reduce(list, graph, &(add_vertex(&2, &1, fun)))
  end

  @doc """
  Fetch a vertex by its label from the graph

  If the a matching vertex is found then `{:ok, vertex} is returned.
  Else `:error` is returned.
  """
  @spec fetch_vertex(graph :: Dag.t, label :: atom) :: {:ok, Vertex.t} | :error
  def fetch_vertex(%__MODULE__{vertices: vertices}, label),
    do: Map.fetch(vertices, label)

  @doc """
  Gets a vertex by its label from the graph

     vertex = EctoFixtures.Dag.get_vertex(graph, :foo)
  """
  @spec get_vertex(graph :: Dag.t, label :: atom) :: Vertex.t | nil
  def get_vertex(%__MODULE__{vertices: vertices}, label),
    do: Map.get(vertices, label)

  @doc """
  Adds an edge between two existing vertecies in the graph

      graph =
        %EctoFixtures.Dag{}
        |> EctoFixtures.Dag.add_vertices([:foo, :bar])
        |> EctoFixtures.Dag.add_edge([:foo, :bar])

  The argument order matters. The 2nd argument is the parent vertex, the 3rd
  argument is the child vertex. In other words. The child becomes the outbound edge for the
  parent and the parent becomes the inbound edge for the child.
  """
  @spec add_edge(graph :: Dag.t, from :: atom, to :: atom) :: Dag.t
  def add_edge(graph, from_label, to_label) do
    %{^from_label => from, ^to_label => to} = graph.vertices

    case Enum.member?(from.out_edges, to_label) do
      false ->
        detect_cycle(graph, from, to)

        out_edges = List.insert_at(from.out_edges, -1, to_label)
        in_edges = List.insert_at(to.in_edges, -1, from_label)

        from = struct(from, out_edges: out_edges)
        to = struct(to, in_edges: in_edges)

        graph
        |> put_vertex(from)
        |> put_vertex(to)
      true -> graph
    end
  end

  @doc """
  Topologically sort the graph

      EctoFixtures.Dag.topsort(graph)

  You can optionally pass a subset to limit the vertices in the graph to
  sort against. Keep in mind, that vertices that are edges of any in the subset
  will be included in the final sorted list

      EctoFixtures.Dag.topsort(graph, [:foo, :bar])
  """
  @spec topsort(graph :: Dag.t) :: list
  def topsort(graph), do: topsort(graph, graph.vertices)

  @spec topsort(graph :: Dag.t, subset :: list) :: list
  def topsort(graph, subset) when is_list(subset) do
    subset = Enum.into(subset, %{}, &({&1, true}))
    topsort(graph, subset)
  end

  @spec topsort(graph :: Dag.t, subset :: map) :: list
  def topsort(graph, subset) when is_map(subset) do
    graph.vertices
    |> Enum.reduce({[], %{}}, fn
      # Filter out all vertices that have in_edges, these cannot be a root vertex
      {_label, %Vertex{in_edges: in_edges}}, acc when length(in_edges) > 0 -> acc
      {label, vertex}, acc ->
        case Map.has_key?(subset, label) do
          true -> 
            acc = acc_for_topsort(label, acc)
            walk(graph, vertex.out_edges, acc, &acc_for_topsort/2)
          false -> acc
        end
    end)
    |> elem(0)
  end

  defp acc_for_topsort(acc_type, {_, acc}) when acc_type in [:acc, :next_acc], do: acc
  defp acc_for_topsort(label, {sorted, visited}) do
    sorted = List.insert_at(sorted, -1, label)
    visited = Map.put(visited, label, true)
    {sorted, visited}
  end

  defp detect_cycle(_graph, %Vertex{label: label}, %Vertex{label: label}),
    do: raise CycleError, "cycle detected: `#{inspect(label)} -> #{inspect(label)}`"
  defp detect_cycle(_graph, %Vertex{out_edges: []}, %Vertex{out_edges: []}), do: nil
  defp detect_cycle(graph, %Vertex{label: from_label} = from, %Vertex{out_edges: to_out_edges, label: to_label} = to) do
    if Enum.member?(to_out_edges, from_label) do
      raise CycleError, "cycle detected: `#{inspect(to_label)} -> #{inspect(from_label)} -> #{inspect(to_label)}`"
    end

    target_label = from.label

    try do
      walk(graph, to.out_edges, [to.label], cycle_raise(target_label))
    rescue error in CycleError ->
      raise CycleError, "#{error.message} -> #{inspect(to.label)}`"
    end
  end

  defp cycle_raise(target_label) do
    fn
      :acc, {acc, _next_acc} -> acc
      :next_acc, {_acc, next_acc} -> next_acc
      ^target_label, path ->
        path_msg =
          path
          |> Enum.reverse()
          |> Enum.map(&(inspect(&1)))
          |> Enum.join(" -> ")

        raise CycleError, "cycle detected: `#{path_msg} -> #{inspect(target_label)}"
      head_label, path -> [head_label | path]
    end
  end

  defp walk(_graph, [], acc, _fun), do: acc
  defp walk(graph, [head_label | tail], acc, fun) do
    next_acc = fun.(head_label, acc)
    next_vertex = get_vertex(graph, head_label)
    next_acc = walk(graph, next_vertex.out_edges, next_acc, fun)
    acc = fun.(:acc, {acc, next_acc})
    walk(graph, tail, acc, fun)
  end
end