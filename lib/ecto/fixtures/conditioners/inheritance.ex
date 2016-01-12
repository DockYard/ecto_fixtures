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

    other_row_data = EctoFixtures.read(other_source)
    |> EctoFixtures.parse
    |> EctoFixtures.Conditioner.process(source: source)
    |> get_in([String.to_atom(other_source), other_table_name, :rows, other_row_name, :data])
    |> Map.delete(:id)

    other_data =
      %{}
      |> put_in([table_name], %{})
      |> put_in([table_name, row_name], other_row_data)

    EctoFixtures.Conditioners.Override.process(data, [source: source, override: other_data, reverse: true])
    |> get_in(path ++ [:data])
  end

  defp inherits_data(data, path, {{:., _, [{other_table_name, _, _}, other_row_name]}, _, _}) do
    path =
      path
      |> List.replace_at(1, other_table_name)
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    get_in(data, path) |> EctoFixtures.Conditioner.escape_values
  end

  defp inherits_data(data, path, {other_row_name, _, _}) do
    path =
      path
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    get_in(data, path) |> EctoFixtures.Conditioner.escape_values
  end
end
