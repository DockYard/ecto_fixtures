defmodule EctoFixtures.Overrider do
  def override(data, nil), do: data

  def override(data, override_data) do
    Enum.reduce override_data, data, fn({table_name, rows}, data) ->
      case data[table_name] do
        nil -> data
        _ -> Enum.reduce rows, data, fn({row_name, columns}, data) ->
          result = case data[table_name][:rows][row_name] do
            nil -> data
            _ -> put_in data[table_name][:rows][row_name][:data], Map.merge(data[table_name][:rows][row_name][:data], columns)
          end
        end
      end
    end
  end
end
