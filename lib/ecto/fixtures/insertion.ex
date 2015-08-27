defmodule Ecto.Fixtures.Insertion do
  def insert(data) do
    Enum.into data, %{}, fn({type, attributes} = data) ->
      put_in attributes.rows, Enum.into(attributes.rows, %{}, fn({type, columns}) ->
        {type, attributes.repo.insert!(Map.merge(attributes.model.__struct__, columns))}
      end)

      {type, attributes}
    end
  end
end
