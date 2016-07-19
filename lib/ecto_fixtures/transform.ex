defmodule EctoFixtures.Transform do
  @reserved ~w(__dag__ __data__)a

  def process(acc, transforms) do
    Enum.reduce(transforms, acc, fn
      [[], opts], acc ->
        transform(acc, Map.keys(acc), opts)
      [row_names, opts], acc ->
        transform(acc, row_names, opts)
    end)
  end

  defp transform(acc, [], _opts), do: acc
  defp transform(acc, [row_name | row_names], opts) when row_name in @reserved,
    do: transform(acc, row_names, opts)
  defp transform(acc, [row_name | row_names], opts) do
    acc
    |> transform(row_name, opts)
    |> transform(row_names, opts)
  end
  defp transform(acc, row_name, opts) do
    with {:ok, override} <- Keyword.fetch(opts, :with),
         {:ok, row} <- Map.fetch(acc, row_name),
         {:ok, columns} <- Map.fetch(row, :columns) do
           override = case override do
             transform_fn when is_function(transform_fn) ->
               transform_fn.(row_name, get_in(acc, [row_name, :columns]))
              override -> override
           end
           columns = Map.merge(columns, override)
           put_in(acc, [row_name, :columns], columns)
    else
      :error -> acc
    end
  end
end
