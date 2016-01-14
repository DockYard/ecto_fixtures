defmodule EctoFixtures.Insertion do
  def process(data, insert?) do
    sorted_paths = :digraph_utils.topsort(get_in(data, [:__DAG__]))

    Enum.reduce sorted_paths, %{}, fn([_, table_name, _, row_name]=path, rows) ->
      case insert_row(get_in(data, path), get_in(data, Enum.take(path, 2)), insert?) do
        nil -> rows
        record ->
          row =
            %{}
            |> put_in([table_name], %{})
            |> put_in([table_name, row_name], record)

          EctoFixtures.Utils.deep_merge(rows, row)
      end
    end
  end

  defp insert_row(%{data: _columns, virtual: true}, _attributes, _insert?), do: nil
  defp insert_row(%{data: columns}, attributes, insert?) when insert? == false do
    struct(attributes.model, columns)
  end
  defp insert_row(row, attributes, insert?) when insert? == true do
    insert_row(row, attributes, false)
    |> attributes.repo.insert!()
  end
end
