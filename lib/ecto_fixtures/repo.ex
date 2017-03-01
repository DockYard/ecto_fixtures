defmodule EctoFixtures.Repo do
  defmacro __using__([with: mods]) do
    quote do
      @fixture_mods unquote(mods)

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
      @data Enum.reduce(@fixture_mods, %{}, fn(mod, data) ->
        mod.data()
        |> Enum.reduce(data, fn({name, attributes}, data) ->
          case Map.fetch(data, name) do
            :error ->
              {groups, attributes} = Map.pop(attributes, :groups)

              data = Map.put(data, name, attributes)

              groups
              |> List.wrap()
              |> Enum.reduce(data, fn(group, data) ->
                case Map.fetch(data, group) do
                  :error -> Map.put(data, group, [name])
                  {:ok, grouped_fixtures} ->
                    Map.put(data, group, List.insert_at(grouped_fixtures, -1, name))
                end
              end)
            {:ok, other_attributes} ->
              raise ArgumentError, "#{inspect(attributes.mod)} attempted to define fixture #{inspect(name)} but that fixture name is already being used in #{inspect(other_attributes.mod)}"
          end
        end)
      end)

      def data(), do: @data
    end
  end
end
