defmodule EctoFixtures do
  defmacro group(name) when is_list(name) do
    quote do
      raise ArgumentError, "you attempted to pass #{inspect(unquote(name))} to &group/1 but it does not accept lists. Perhaps you need to use &groups/1 instead?"
    end
  end

  defmacro group(name) when is_binary(name) do
    quote do
      unquote(name)
      |> String.to_atom()
      |> group()
    end
  end

  defmacro group(group) do
    quote do
      cond do
        Enum.member?(@fixtures, unquote(group)) ->
          raise ArgumentError, "#{inspect(__MODULE__)} attempting to use #{inspect(unquote(group))} as a group name but it is already claimed by a fixture"
        true -> @groups unquote(group)
      end
    end
  end

  defmacro groups(groups) when is_list(groups) do
    quote do
      unquote(groups)
      |> Enum.reverse()
      |> Enum.each(&(group(&1)))
    end
  end

  defmacro groups(name) do
    quote do
      raise ArgumentError, "you attempted to pass #{inspect(unquote(name))} to &groups/1 but it only accepts lists. Perhaps you need to use &group/1 instead?"
    end
  end

  defmacro repo(repo, context \\ :default) do
    quote do
      @repos {unquote(context), unquote(repo)}
    end
  end

  defmacro schema(schema) do
    quote do
      @schema unquote(schema)
    end
  end

  defmacro serializer(serializer, context \\ :default) do
    quote do
      @serializers {unquote(context), unquote(serializer)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def data do
        Enum.into(@fixtures, %{}, fn(name) ->
          columns = apply(__MODULE__, name, [])

          attributes = %{
            mod: __MODULE__,
            repos: @repos,
            schema: @schema,
            columns: columns
          }

          attributes = case @serializers do
            [] -> attributes
            serializers -> Map.put(attributes, :serializers, serializers)
          end

          attributes = case @groups do
            [] -> attributes
            groups -> Map.put(attributes, :groups, groups)
          end

          {name, attributes}
        end)
      end
    end
  end

  @reserved_names [:repo, :schema, :serializer, :group, :groups, :data]

  def __on_definition__(env, :def, name, _args, _guards, _expr) when not name in @reserved_names do
    module = env.module
    groups = Module.get_attribute(module, :groups)

    cond do
      Enum.member?(groups, name) ->
        raise ArgumentError, "#{inspect(module)} attempting to use #{inspect(name)} as a fixture name but it is already claimed as the group name"
      true ->
        Module.put_attribute(env.module, :fixtures, name)
    end
  end
  def __on_definition__(_env, _type, _name, _args, _guards, _expr), do: nil

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :repos, accumulate: true)
      Module.register_attribute(__MODULE__, :groups, accumulate: true)
      Module.register_attribute(__MODULE__, :schema, accumulate: false)
      Module.register_attribute(__MODULE__, :fixtures, accumulate: true)
      Module.register_attribute(__MODULE__, :serializers, accumulate: true)

      import EctoFixtures

      @before_compile EctoFixtures
      @on_definition EctoFixtures
    end
  end
end
