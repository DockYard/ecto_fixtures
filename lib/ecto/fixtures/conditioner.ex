defmodule EctoFixtures.Conditioner do
  import EctoFixtures.Conditioners.Inheritance, only: [inheritance: 2]
  import EctoFixtures.Conditioners.Override, only: [override: 2]
  import EctoFixtures.Conditioners.PrimaryKey, only: [primary_key: 2, generate_key_value: 3]
  import EctoFixtures.Conditioners.Associations, only: [associations: 2]
  import EctoFixtures.Conditioners.FunctionCall, only: [function_call: 2]

  def condition(data, opts) do
    Enum.reduce data, data, fn({path, _}, data) ->
      condition_tables(data, [path], opts)
    end
  end

  def condition_tables(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({table_name, _}, data) ->
      condition_table(data, path ++ [table_name, :rows], opts)
    end
  end

  defp condition_table(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({row_name, _}, data) ->
      condition_row(data, path ++ [row_name], opts)
    end
  end

  defp condition_row(data, path, opts) do
    data
    |> inheritance(path)
    |> override(opts)
    |> primary_key(path)
    |> associations(path)
    |> function_call(path)
  end

  def escape_values(map) do
    Enum.into map, %{}, fn({key, value}) -> {key, Macro.escape(value)} end
  end
end
