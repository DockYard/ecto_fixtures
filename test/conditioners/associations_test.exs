defmodule EctoFixtures.Conditioners.AssociationsTest do
  use ExUnit.Case

  test "sets foreign key for has_one association properly and removes association" do
    path = "test/fixtures/associations_has_one.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)

    assert is_nil(data[path][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:owners][:rows][:brian][:data], :pet)
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    path = "test/fixtures/associations_belongs_to.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)

    assert is_nil(data[path][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:pets][:rows][:boomer][:data], :owner)
  end

  test "sets foreign key for has_many association properly and removes association" do
    path = "test/fixtures/associations_has_many.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)

    assert is_nil(data[path][:cars][:rows][:nissan][:data][:owner_id])
    assert is_nil(data[path][:cars][:rows][:tesla][:data][:owner_id])
    refute is_nil(data[path][:owners][:rows][:brian][:data][:cars])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:cars][:rows][:nissan][:data][:owner_id])
    assert is_integer(data[path][:cars][:rows][:tesla][:data][:owner_id])
    refute Map.has_key?(data[path][:owners][:rows][:brian][:data], :cars)
  end
end
