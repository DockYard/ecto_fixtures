defmodule EctoFixtures.Conditioners.DAGTest do
  use ExUnit.Case

  test "inserts DAG into payload" do
    source = "test/fixtures/conditioner.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert Map.has_key?(data, :__DAG__)
  end

  test "DAG ordering continues for deeply nested assocations" do
    source = "test/fixtures/dag/deep/invoices.exs"

    data =
      source
      |> EctoFixtures.read()
      |> EctoFixtures.parse()
      |> EctoFixtures.condition()

    dag = data[:__DAG__]

    invoice_vtx = [:"test/fixtures/dag/deep/invoices.exs", :invoices, :rows, :one]
    owner_vtx = [:"test/fixtures/dag/deep/users.exs", :users, :rows, :owner]
    renter_vtx = [:"test/fixtures/dag/deep/users.exs", :users, :rows, :renter]
    property_vtx = [:"test/fixtures/dag/deep/properties.exs", :properties, :rows, :one]

    assert :digraph.get_path(dag, owner_vtx, invoice_vtx) == [owner_vtx, invoice_vtx]
    assert :digraph.get_path(dag, renter_vtx, invoice_vtx) == [renter_vtx, invoice_vtx]
    assert :digraph.get_path(dag, property_vtx, invoice_vtx) == [property_vtx, invoice_vtx]

    assert :digraph.get_path(dag, owner_vtx, property_vtx) == [owner_vtx, property_vtx]
    assert :digraph.get_path(dag, renter_vtx, property_vtx) == [renter_vtx, property_vtx]
  end
end
