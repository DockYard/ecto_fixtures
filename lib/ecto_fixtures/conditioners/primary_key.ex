defmodule EctoFixtures.Conditioners.PrimaryKey do
  @max_id trunc(:math.pow(2, 30) - 1)

  def process(acc, row_name) do
    schema = get_in(acc, [row_name, :schema])
    case schema.__schema__(:primary_key) do
      [primary_key] -> generate_key_value(acc, row_name, primary_key)
      [] -> acc
    end
  end

  def generate_key_value(acc, row_name, key) do
    schema = get_in(acc, [row_name, :schema])
    key_path = [row_name, :columns, key]
    case get_in(acc, key_path) |> is_nil() do
      true ->
        key_type = schema.__schema__(:type, key)
        name = Enum.join(key_path, "-")

        value = case key_type do
          :id -> generate_id_key_value(name)
          :binary_id -> generate_binary_id_key_value(name)
        end

        put_in(acc, key_path, value)
      false -> acc
    end
  end

  defp generate_id_key_value(name) do
    :zlib.crc32(:zlib.open(), name)
    |> rem(@max_id)
  end

  defp generate_binary_id_key_value(name) do
    UUID.uuid5(:oid, name)
  end
end
