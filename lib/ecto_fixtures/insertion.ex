defmodule EctoFixtures.Insertion do
  def process(acc, opts) do
    sorted_row_names = :digraph_utils.topsort(get_in(acc, [:__dag__]))

    Enum.reduce(sorted_row_names, %{}, fn(row_name, records) ->
      case insert_row(acc[row_name], insert?(row_name, opts)) do
        nil -> records
        record -> Map.put(records, row_name, record)
      end
    end)
  end

  defp insert_row(%{virtual: true}, _insert?), do: nil
  defp insert_row(%{columns: columns, model: model}, false) do
    struct(model, columns)
  end
  defp insert_row(record, false), do: record
  defp insert_row(%{repo: repo} = row, true) do
    insert_row(row, false)
    |> repo.insert!()
  end

  defp insert?(_row_name, nil), do: true
  defp insert?(_row_name, false), do: false
  defp insert?(_row_name, true), do: true
  defp insert?(_row_name, []), do: true
  defp insert?(row_name, opts) do
    case Keyword.fetch(opts, :only) do
      {:ok, only} ->
        case Keyword.fetch(opts, :except) do
          {:ok, except} ->
            Enum.member?(only -- except, row_name)
          :error ->
            Enum.member?(only, row_name)
        end
      :error ->
        case Keyword.fetch(opts, :except) do
          {:ok, except} ->
            !Enum.member?(except, row_name)
          :error -> true
        end
    end
  end
end
