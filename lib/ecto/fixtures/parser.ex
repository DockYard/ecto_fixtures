defmodule EctoFixtures.Parser do
  def parse(content) do
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

  defp _parse_table({name, _, table_data}) do
    Map.put(%{}, name, _parse_table_arguments(table_data))
  end

  defp _parse_table_arguments([[do: {:__block__, [], rows}]]=arguments) when length(arguments) == 1 do
    _parse_table_rows(rows)
  end
  defp _parse_table_arguments([[do: row]]) when is_tuple(row) do
    _parse_table_rows([row])
  end
  defp _parse_table_arguments([options|tail]=arguments) when length(arguments) > 1 do
    _parse_table_options(options)
    |> Map.merge(%{rows: _parse_table_arguments(tail) })
  end

  defp _parse_table_options([]), do: %{}
  defp _parse_table_options([{type, quote}|tail]) do
    Map.put(%{}, type, Code.eval_quoted(quote) |> Tuple.to_list |> List.first)
    |> Map.merge(_parse_table_options(tail))
  end

  defp _parse_table_rows([]), do: %{}
  defp _parse_table_rows([row|tail]) do
    _parse_row(row)
    |> Map.merge(_parse_table_rows(tail))
  end

  defp _parse_row({name, _, args}) do
    Map.put(%{}, name, _parse_row_args(args))
  end

  defp _parse_row_args([]), do: %{}
  defp _parse_row_args([[do: {:__block__, _, columns}]|tail]) do
    Map.merge(%{data: _parse_columns(columns)}, _parse_row_args(tail))
  end
  defp _parse_row_args([[do: column]|tail]) do
    _parse_row_args([[do: {:__block__, [], [column]}]|tail])
  end
  defp _parse_row_args([[{arg_key, arg_value}]|tail]) do
    Map.put(%{}, arg_key, arg_value)
    |> Map.merge(_parse_row_args(tail))
  end

  defp _parse_columns([]), do: %{}
  defp _parse_columns([{field, _, [value]}|tail]) do
    Map.put(%{}, field, value)
    |> Map.merge(_parse_columns(tail))
  end
end
