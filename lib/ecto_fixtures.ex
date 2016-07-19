defmodule EctoFixtures do
  @doc false
  def create_acc(data) do
    %{
      __dag__: EctoFixtures.Dag.create(),
      __data__: data
    }
  end

  defmacro __using__(opts) do
    root    = opts[:path] || "test/fixtures"
    pattern = "**/*.fixtures"

    fixture_paths = find_all(root, pattern)

    data_ast = Enum.reduce(fixture_paths, %{}, fn(fixture_path, acc) ->
      EctoFixtures.Parser.process(acc, fixture_path)
    end)
    |> Macro.escape()

    quote do
      @data unquote(data_ast)

      for fixture_path <- unquote(fixture_paths) do
        @external_resource fixture_path
      end

      @doc false
      def fixture_data(), do: @data

      def __ecto_fixtures_recompile__?() do
        unquote(hash(root, pattern)) != EctoFixtures.hash(unquote(root), unquote(pattern))
      end
    end
  end

  @doc false
  def find_all(root, pattern) do
    Path.join(root, pattern)
    |> Path.wildcard()
  end

  @doc false
  def hash(root, pattern) do
    find_all(root, pattern)
    |> Enum.sort()
    |> :erlang.md5()
  end
end
