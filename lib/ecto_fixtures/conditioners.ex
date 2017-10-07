defmodule EctoFixtures.Conditioners do
  def process(acc, row_name) do
    acc
    |> EctoFixtures.Conditioners.PrimaryKey.process(row_name)
    |> EctoFixtures.Conditioners.Associations.process(row_name)
  end
end
