defmodule EctoFixtures.Insertion do
  def insert(data, insert?) do
    Enum.reduce data, %{}, fn({source, tables}, acc) ->
      Enum.into tables, acc, fn({type, attributes}) ->
        attributes = put_in attributes[:rows], Enum.reduce(attributes[:rows], %{}, fn(row, rows) ->
          insert_row(row, rows, attributes, insert?)
        end)

        {type, attributes}
      end
    end
  end

  defp insert_row({_type, %{data: _columns, virtual: true}}, rows, _attributes, _insert?), do: rows
  defp insert_row({type, %{data: columns}}, rows, attributes, insert?) when insert? == false do
    Map.put(rows, type, struct(attributes.model, columns))
  end
  defp insert_row({type, %{}}=row, rows, attributes, insert?) when insert? == true do
    rows = insert_row(row, rows, attributes, false)
    Map.put(rows, type, attributes.repo.insert!(rows[type]))
  end
end
