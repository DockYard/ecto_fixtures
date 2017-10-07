defmodule EctoFixtures.Case do

  defmacro insert(opts \\ [])
  defmacro insert(opts) do
    quote do
      @insert unquote(opts)
    end
  end

  defmacro reload(opts \\ [])
  defmacro reload(opts) do
    quote do
      @reload unquote(opts)
    end
  end

  defmacro fixture(name) do
    quote do
      fixtures([unquote(name)])
    end
  end
  defmacro fixtures(names) do
    quote do
      @fixtures unquote(names)
    end
  end

  defmacro context(context) do
    quote do
      @context unquote(context)
    end
  end

  defmacro serialize(opts \\ [])
  defmacro serialize(true) do
    quote do
      serialize([])
    end
  end
  defmacro serialize(opts) do
    quote do
      @serialize unquote(opts)
    end
  end

  defmacro transform(opts) do
    quote do
      transform([], unquote(opts))
    end
  end
  defmacro transform(names, opts) do
    quote do
      @transforms [unquote(names), unquote(opts)]
    end
  end

  defmacro __using__([with: mod]) do
    quote do
      import EctoFixtures.Case

      ExUnit.Case.register_attribute(__MODULE__, :insert, accumulate: false)
      ExUnit.Case.register_attribute(__MODULE__, :reload, accumulate: false)
      ExUnit.Case.register_attribute(__MODULE__, :fixtures, accumulate: true)
      ExUnit.Case.register_attribute(__MODULE__, :context, accumulate: false)
      ExUnit.Case.register_attribute(__MODULE__, :serialize, accumulate: false)
      ExUnit.Case.register_attribute(__MODULE__, :transforms, accumulate: true)

      setup context do
        mod = unquote(mod)

        ctx =
          context.registered
          |> Map.fetch(:context)
          |> case do
            :error -> :default
            {:ok, nil} -> :default
            {:ok, ctx} -> ctx
          end

        acc =
          mod.data()
          |> EctoFixtures.Acc.build()
          |> EctoFixtures.Reducer.process(context.registered.fixtures)
          |> EctoFixtures.Transform.process(context.registered.transforms)

        data =
          acc
          |> EctoFixtures.Insertion.process(context.registered.insert, ctx)
          |> EctoFixtures.Reloader.process(context.registered.reload, acc, ctx)
          |> EctoFixtures.Serializer.process(context.registered.serialize, mod, ctx)

        {:ok, [data: data]}
      end
    end
  end
end
