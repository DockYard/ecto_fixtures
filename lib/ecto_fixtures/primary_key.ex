defmodule EctoFixtures.PrimaryKey do
  @max_id trunc(:math.pow(2, 30) - 1)

  def process(%{schema: schema} = attributes, row_name) do
    case schema.__schema__(:primary_key) do
      [primary_key] -> generate_key_value(attributes, row_name, primary_key)
      [] -> attributes
    end
  end

  def generate_key_value(%{schema: schema} = attributes, row_name, key) do
    key_path = [:columns, key]

    attributes
    |> get_in(key_path)
    |> is_nil()
    |> case do
      true ->
        key_type = schema.__schema__(:type, key)

        name =
          key_path
          |> List.insert_at(0, row_name)
          |> Enum.join("-")

        value = case key_type do
          :id -> generate_id_key_value(name)
          :binary_id -> generate_binary_id_key_value(name)
        end

        put_in(attributes, key_path, value)
      false -> attributes
    end
  end

  defp generate_id_key_value(name) do
    :zlib.open()
    |> :zlib.crc32(name)
    |> rem(@max_id)
  end

  defp generate_binary_id_key_value(name) do
    UUID.uuid5(:oid, name)
  end
end