defmodule EctoFixtures.Insertion do
  def process(acc, opts, context \\ :default) do
    sorted_row_names = :digraph_utils.topsort(get_in(acc, [:__dag__]))

    Enum.reduce(sorted_row_names, %{}, fn(row_name, records) ->
      case insert_row(acc[row_name], insert?(row_name, opts), context) do
        nil -> records
        record -> Map.put(records, row_name, record)
      end
    end)
  end

  defp insert_row(%{virtual: true}, _insert?, _context), do: nil
  defp insert_row(%{columns: columns, schema: schema}, false, _context) do
    struct(schema, columns)
  end
  defp insert_row(record, false, _context), do: record
  defp insert_row(%{repos: repos} = row, true, context) do
    repo = case Keyword.fetch(repos, context) do
      :error -> Keyword.get(repos, :default)
      {:ok, repo} -> repo
    end

    insert_row(row, false, context)
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
