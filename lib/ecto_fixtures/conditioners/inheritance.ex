defmodule EctoFixtures.Conditioners.Inheritance do

  def process(acc, row_name) do
    data = Map.get(acc, :__data__)

    with {:ok, row_data} <- Map.fetch(acc, row_name),
         {:ok, _columns} <- Map.fetch(row_data, :columns),
         {:ok, inherits} <- Map.fetch(row_data, :inherits) do
      inherit_row =
        (acc[inherits] || data[inherits])
        |> remove_primary_key()

      put_in(acc, [row_name, :columns], Map.merge(inherit_row[:columns], acc[row_name][:columns]))
    else
      :error ->
        acc
    end
  end

  defp remove_primary_key(inherit_row) do
    [primary_key] = inherit_row[:model].__schema__(:primary_key)
    {_, inherit_row} = pop_in(inherit_row, [:columns, primary_key])

    inherit_row
  end
end
