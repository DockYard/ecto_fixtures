defmodule EctoFixtures.Conditioners.DAGTest do
  use ExUnit.Case

  test "inserts DAG into payload" do
    source = "test/fixtures/conditioner.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert Map.has_key?(data, :__DAG__)
  end
end
