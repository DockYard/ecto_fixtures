defmodule EctoFixtures.Conditioners.Inheritance do

  def process(data, path) do
    if get_in(data, path) |> Map.has_key?(:inherits) do
      put_in(data, path ++ [:data],
        Map.merge(inherits_data(data, path, get_in(data, path ++ [:inherits])), get_in(data, path ++ [:data])))
    else
      data
    end
  end

  defp inherits_data(data, path, {{:., _, [{{:., _, [{:fixtures, _, [file_path]}, other_table_name]}, _, _}, other_row_name]}, _, _}) do
    other_source = "test/fixtures/#{file_path}.exs"
    [source, table_name, :rows, row_name] = path

    other_source_atom = String.to_atom(other_source)

    other_row_data = EctoFixtures.read(other_source)
    |> EctoFixtures.parse
    |> EctoFixtures.Conditioner.process(source: source)
    |> remove_primary_key([other_source_atom, other_table_name, :rows, other_row_name, :data])
    |> get_in([other_source_atom, other_table_name, :rows, other_row_name, :data])

    other_data = %{
      table_name => %{
        row_name => other_row_data
      }
    }

    EctoFixtures.Conditioners.Override.process(data, [source: source, override: other_data, reverse: true])
    |> get_in(path ++ [:data])
  end

  defp inherits_data(data, path, {{:., _, [{other_table_name, _, _}, other_row_name]}, _, _}) do
    path =
      path
      |> List.replace_at(1, other_table_name)
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    data
    |> remove_primary_key(path)
    |> get_in(path)
    |> EctoFixtures.Conditioner.escape_values()
  end

  defp inherits_data(data, path, {other_row_name, _, _}) do
    path =
      path
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    data
    |> remove_primary_key(path)
    |> get_in(path)
    |> EctoFixtures.Conditioner.escape_values()
  end

  defp remove_primary_key(data, [source, table_name, :rows, row_name, :data]=path) do
    primary_key = get_in(data, [source, table_name, :model]).__schema__(:primary_key)
    put_in(data, path, Map.delete(get_in(data, path), :id))
  end
end
