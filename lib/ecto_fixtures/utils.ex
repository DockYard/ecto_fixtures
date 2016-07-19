defmodule EctoFixtures.Utils do
  def deep_merge(left, right) when is_map(left) and is_map(right) do
    Enum.into right, left, fn({key, value}) ->
      if Map.has_key?(left, key) do
        {key, deep_merge(left[key], value)}
      else
        {key, value}
      end
    end
  end

  def deep_merge(left, right) when is_list(left) and is_list(right) do
    Enum.reduce right, left, fn({key, value}, data) ->
      tuple = if Keyword.has_key?(data, key) do
        {key, deep_merge(left[key], value)}
      else
        {key, value}
      end

      Keyword.merge(data, Keyword.new([tuple]))
    end
  end
  def deep_merge(_left, right), do: right
end
