defmodule Fixtures.Conditioner do
  require IEx
  def condition(data) do
    Map.keys(data)
    |> Enum.into(%{}, fn(table_name) -> {table_name, _condition_table(table_name, data[table_name])} end)
  end

  defp _condition_table(table_name, data) do
    Map.put(data, :rows, _condition_rows(Map.to_list(data.rows), table_name, data.model))
  end

  defp _condition_rows([], _table_name, _model), do: %{}
  defp _condition_rows([{label, columns}|tail], table_name, model) do
    columns = columns
    |> _condition_primary_key(label, table_name, model)

    Map.put(%{}, label, columns)
    |> Map.merge(_condition_rows(tail, table_name, model))
  end
  
  defp _condition_primary_key(columns, label, table_name, model) do
    [primary_key] = model.__schema__(:primary_key)

    if is_nil(columns[primary_key]) do
      primary_key_type = model.__schema__(:type, primary_key)

      columns = case primary_key_type do
        :id ->
          Map.put(columns, primary_key, _generate_id_primary_key_value(primary_key, label, table_name))
        :binary_id ->
          Map.put(columns, primary_key, _generate_binary_id_primary_key_value(primary_key, label, table_name))
      end

    end

    columns
  end

  defp _generate_id_primary_key_value(primary_key, label, table_name) do
    :zlib.crc32(:zlib.open, "#{primary_key}-#{label}-#{table_name}")
  end

  defp _generate_binary_id_primary_key_value(primary_key, label, table_name) do
    UUID.uuid5(:oid, "#{primary_key}-#{label}-#{table_name}")
  end
end
