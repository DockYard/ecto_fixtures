defmodule EctoFixtures.Parser do
  def process({path, content}) do
    {:ok, ast} = Code.string_to_quoted(content)
    Map.put(%{}, path, parse_ast(ast))
  end

  defp parse_ast({:__block__, _, tables}) when is_list(tables) do
    parse_tables(tables)
  end
  defp parse_ast(table) do
    parse_tables([table])
  end

  defp parse_tables(tables) do
    Enum.reduce tables, [], fn(table, acc) ->
      parse_table(table)
      |> Keyword.merge(acc)
    end
  end

  defp parse_table({name, _, table_data}) do
    [{name, parse_table_arguments(table_data)}]
  end

  defp parse_table_arguments([[do: {:__block__, [], rows}]]=arguments) when length(arguments) == 1 do
    parse_table_rows(rows)
  end
  defp parse_table_arguments([[do: row]]) when is_tuple(row) do
    parse_table_rows([row])
  end
  defp parse_table_arguments([options|tail]=arguments) when length(arguments) > 1 do
    %{rows: parse_table_arguments(tail)}
    |> Map.merge(parse_table_options(options))
  end

  defp parse_table_options([]), do: %{}
  defp parse_table_options([{type, quoted}|tail]) do
    Map.put(%{}, type, elem(Code.eval_quoted(quoted), 0))
    |> Map.merge(parse_table_options(tail))
  end

  defp parse_table_rows([]), do: []
  defp parse_table_rows([row|tail]) do
    parse_table_rows(tail)
    |> Keyword.merge(parse_row(row))
  end

  defp parse_row({name, _, args}) do
    [{name, parse_row_args(args)}]
  end

  defp parse_row_args([]), do: %{}
  defp parse_row_args([[do: {:__block__, _, columns}]|tail]) do
    parse_row_args(tail)
    |> Map.merge(%{data: parse_columns(columns)})
  end
  defp parse_row_args([[do: column]|tail]) do
    parse_row_args([[do: {:__block__, [], [column]}]|tail])
  end
  defp parse_row_args([[{arg_key, arg_value}]|tail]) do
    Map.put(%{}, arg_key, arg_value)
    |> Map.merge(parse_row_args(tail))
  end

  defp parse_columns([]), do: %{}
  defp parse_columns([{field, _, [value]}|tail]) do
    Map.put(%{}, field, value)
    |> Map.merge(parse_columns(tail))
  end
end
