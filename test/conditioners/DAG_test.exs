defmodule EctoFixtures.Conditioners.DAGTest do
  use ExUnit.Case

  test "inserts DAG into payload" do
    path = "test/fixtures/conditioner.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert Map.has_key?(data, :__DAG__)
  end
end
