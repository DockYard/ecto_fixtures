defmodule EctoFixtures.Normalizer do
  def normalize(data) do
    Enum.into data, %{}, fn({type, attributes}) ->
      attributes = attributes
      |> Map.merge(_hoist_row_data(attributes.rows))
      |> Map.delete(:model)
      |> Map.delete(:repo)
      |> Map.delete(:rows)

      {type, attributes}
    end
  end

  def _hoist_row_data(rows) do
    Enum.into rows, %{}, fn({row_name, attributes}) ->
      {row_name, attributes.data}
    end
  end
end
