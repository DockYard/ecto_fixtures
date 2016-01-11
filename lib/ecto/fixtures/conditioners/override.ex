defmodule EctoFixtures.Conditioners.Override do
  def override(data, [source: source, override: %{}=override_data, reverse: reverse?]=opts) do
    Enum.reduce override_data, data, fn({table_name, rows}, data) ->
      case get_in(data, [source, table_name]) do
        nil -> data
        _ -> Enum.reduce rows, data, fn({row_name, columns}, data) ->
          result = case get_in(data, [source, table_name, :rows, row_name]) do
            nil -> data
            _ ->
              put_in(data, [source, table_name, :rows, row_name, :data], override_merge(get_in(data, [source, table_name, :rows, row_name, :data]), columns, reverse?))
          end
        end
      end
    end
  end
  def override(data, [source: source, override: override_data]) when is_map(override_data), do:
    override(data, [source: source, override: override_data, reverse: false])
  def override(data, _opts), do: data

  defp override_merge(left, right, false) do
    Map.merge(left, right)
  end

  defp override_merge(left, right, true) do
    Map.merge(right, left)
  end
end
