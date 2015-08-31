defmodule EctoFixtures.Normalizer do
  def normalize(data) do
    Enum.into data, %{}, fn({type, attributes}) ->
      attributes = attributes
      |> Map.merge(attributes.rows)
      |> Map.delete(:model)
      |> Map.delete(:repo)
      |> Map.delete(:rows)

      {type, attributes}
    end
  end
end
