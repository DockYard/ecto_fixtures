defmodule EctoFixtures.Acc do
  @doc false
  def build(data) do
    %{
      __dag__: EctoFixtures.Dag.create(),
      __data__: data
    }
  end
end
