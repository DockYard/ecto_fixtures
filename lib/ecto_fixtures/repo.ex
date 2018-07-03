defmodule EctoFixtures.Repo do
  alias EctoFixtures.{Associations, Dag, Dag.Vertex}

  defmacro __using__([with: mods]) do
    quote do
      @fixture_mods unquote(mods)

      # This will force all of the fixture
      # mods to be declared as `required`
      # and enforce proper load order
      for mod <- @fixture_mods do
        quote do
          require unquote(mod)
        end
      end

      @before_compile EctoFixtures.Repo
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @graph EctoFixtures.Repo.build_graph(@fixture_mods)

      def graph(), do: @graph
    end
  end

  def build_graph(mods) do
    mods
    |> Enum.reduce(%Dag{}, &insert_vertices/2)
    |> build_associations()
  end

  defp insert_vertices(mod, graph) do
    Enum.reduce(mod.data(), graph, fn({label, attributes}, graph) ->
      case Dag.fetch_vertex(graph, label) do
        :error -> Dag.add_vertex(graph, label, attributes)
        {:ok, %Vertex{value: other_attributes}} ->
          raise ArgumentError, "#{inspect(attributes.mod)} attempted to define fixture #{inspect(label)} but that fixture name is already being used in #{inspect(other_attributes.mod)}"
      end
    end)
  end

  defp build_associations(graph) do
    Map.keys(graph.vertices)
    |> Enum.reduce(graph, &Associations.process/2)
  end
end