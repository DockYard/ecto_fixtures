defmodule EctoFixtures.Serializer do
  def process(acc, opts, mod, context \\ :default) do
    data = mod.data()
    {row_names, opt} = reduce_names(acc, opts)

    Enum.reduce(row_names, acc, fn(row_name, acc) ->
      row = acc[row_name]
      serializers = case get_in(data, [row_name, :serializers]) do
        nil -> []
        serializers -> serializers
      end
      serializer = case Keyword.fetch(serializers, context) do
        :error -> Keyword.get(serializers, :default)
        {:ok, serializer} -> serializer
      end
      record = serialize(row, serializer, mod, opt)
      Map.put(acc, row_name, record)
    end)
  end

  defp serialize(record, nil, _mod, _opts), do: record
  defp serialize(record, serializer, mod, nil) do
    mod.serialize(record, serializer)
  end
  defp serialize(record, serializer, mod, fun) when is_function(fun) do
    opts = fun.(record)
    mod.serialize(record, serializer, opts)
  end
  defp serialize(record, serializer, mod, opts) do
    mod.serialize(record, serializer, opts)
  end

  def reduce_names(acc, opts) when is_list(opts) do
    keys = Map.keys(acc)

    keys = case Keyword.fetch(opts, :only) do
      {:ok, only} -> only
      :error -> case Keyword.fetch(opts, :except) do
        {:ok, except} -> keys -- except
        :error -> keys
      end
    end

    {keys, Keyword.get(opts, :with)}
  end
  def reduce_names(acc, true),
    do: {Map.keys(acc), nil}
  def reduce_names(_acc, bool) when bool == false or bool == nil,
    do: {[], nil}
end
