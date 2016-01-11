defmodule EctoFixtures.Conditioners.PrimaryKey do
  @max_id trunc(:math.pow(2, 30) - 1)

  def primary_key(data, path) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])
    case model.__schema__(:primary_key) do
      [primary_key] -> generate_key_value(data, path, primary_key)
      [] -> data
    end
  end

  def generate_key_value(data, path, key) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])
    key_path = path ++ [:data, key]
    case get_in(data, key_path) |> is_nil() do
      true ->
        key_type = model.__schema__(:type, key)
        name = Enum.join(key_path, "-")

        value = case key_type do
          :id -> generate_id_key_value(name)
          :binary_id -> generate_binary_id_key_value(name)
        end

        put_in(data, key_path, value)
      false -> data
    end
  end

  defp generate_id_key_value(name) do
    :zlib.crc32(:zlib.open, name)
    |> rem(@max_id)
  end

  defp generate_binary_id_key_value(name) do
    UUID.uuid5(:oid, name)
  end
end
