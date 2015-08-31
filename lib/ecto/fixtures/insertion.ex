defmodule EctoFixtures.Insertion do
  def insert(data, can_insert) do
    Enum.into data, %{}, fn({type, attributes}) ->
      _ = put_in attributes.rows, Enum.reduce(attributes.rows, %{}, fn(row, rows) ->
        _insert(row, rows, attributes, can_insert)
      end)

      {type, attributes}
    end
  end

  defp _insert({_type, %{data: _columns, virtual: true}}, rows, _attributes, _can_insert), do: rows
  defp _insert({type, %{data: columns}}, rows, attributes, can_insert) when can_insert == false do
    Map.put(rows, type, Map.merge(attributes.model.__struct__, columns))
  end
  defp _insert({type, %{}}=row, rows, attributes, can_insert) when can_insert == true do
    rows = _insert(row, rows, attributes, false)
    Map.put(rows, type, attributes.repo.insert!(rows[type]))
  end
end
