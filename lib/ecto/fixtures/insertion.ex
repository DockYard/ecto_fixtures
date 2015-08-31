defmodule EctoFixtures.Insertion do
  require IEx
  def insert(data) do
    Enum.into data, %{}, fn({type, attributes} = data) ->
      put_in attributes.rows, Enum.reduce(attributes.rows, %{}, fn(row, rows) ->
        _insert(row, rows, attributes)
      end)

      {type, attributes}
    end
  end

  defp _insert({type, %{data: columns, virtual: true}}, rows, _attributes), do: rows
  defp _insert({type, %{data: columns}}=row, rows, attributes) do
    Map.put(%{}, type, attributes.repo.insert!(Map.merge(attributes.model.__struct__, columns)))
    |> Map.merge(rows)
  end
end
