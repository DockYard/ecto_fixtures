defmodule EctoFixtures.Reducer do
  def process(acc, names) do
    Enum.reduce(names, acc, fn(row_names, acc) ->
      add_row_names(row_names, acc)
    end)
  end

  defp add_row_names([], acc), do: acc
  defp add_row_names([row_name | names], acc) do
    data = Map.get(acc, :__data__)

    acc = case Map.fetch(acc, row_name) do
      {:ok, _row} -> acc
      :error ->
        case Map.fetch(data, row_name) do
          {:ok, row_data} when is_map(row_data) ->
            acc =
              EctoFixtures.Dag.add_vertex(acc, row_name)
              |> Map.put(row_name, row_data)

            EctoFixtures.Conditioners.process(acc, row_name)

          {:ok, group_rows} when is_list(group_rows) ->
            add_row_names(group_rows, acc)

          :error -> acc
        end
    end

    add_row_names(names, acc)
  end
end
