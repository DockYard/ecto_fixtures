defmodule Fixtures do
  require IEx
  def parse(path) do
    {:ok, content} = File.read(path)
    {:ok, ast} = Code.string_to_quoted(content)
    _parse_ast(ast)
  end

  defp _parse_ast({:__block__, _, tables}) when is_list(tables) do
    _parse_tables(tables)
  end

  defp _parse_ast(table) do
    _parse_tables([table])
  end

  defp _parse_tables(tables) do
    Enum.reduce tables, %{}, fn(table, acc) ->
      Map.merge(acc, _parse_table(table))
    end
  end

  defp _parse_table({name, _, [[do: {:__block__, _, rows}]]}) do
    _parse_table_rows(name, rows)
  end

  defp _parse_table({name, _, [[do: row]]}) do
    _parse_table_rows(name, [row])
  end

  defp _parse_table_rows(name, rows) do
    Map.put(%{}, name, _parse_rows(rows))
  end

  defp _parse_rows(rows) do
    Enum.reduce(rows, %{}, &_add_row_to_map(&1, &2))
  end

  defp _add_row_to_map({name, _, [[do: {_, _, columns}]]}, rows) do
    Map.put(rows, name, _parse_columns(columns))
  end

  defp _parse_columns(columns) do
    Enum.reduce(columns, %{}, &_add_column_to_map(&1, &2))
  end

  defp _add_column_to_map({key, _, [value]}, columns) do
    Map.put(columns, key, value)
  end
end
