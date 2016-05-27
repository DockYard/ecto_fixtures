defmodule EctoFixtures.Conditioner do
  def process(data, opts) do
    data
    |> Map.delete(:__DAG__)
    |> Enum.reduce data, fn({path, _}, data) ->
      walk_tables(data, [path], opts)
    end
  end

  def walk_tables(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({table_name, _}, data) ->
      walk_rows(data, path ++ [table_name, :rows], opts)
    end
  end

  defp walk_rows(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({row_name, _}, data) ->
      condition_row(data, path ++ [row_name], opts)
    end
  end

  defp condition_row(data, path, opts) do
    data
    |> EctoFixtures.Conditioners.DAG.process(path)
    |> EctoFixtures.Conditioners.Inheritance.process(path)
    |> EctoFixtures.Conditioners.Override.process(opts)
    |> EctoFixtures.Conditioners.PrimaryKey.process(path)
    |> EctoFixtures.Conditioners.Associations.process(path)
    |> EctoFixtures.Conditioners.FunctionCall.process(path)
  end

  def escape_values(map) do
    Enum.into map, %{}, fn({key, value}) -> {key, Macro.escape(value)} end
  end
end
