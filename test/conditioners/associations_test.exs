defmodule EctoFixtures.Conditioners.AssociationsTest do
  use ExUnit.Case

  test "sets foreign key for has_one association properly and removes association" do
    path = "test/fixtures/associations/has_one.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)

    assert is_nil(data[path][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:owners][:rows][:brian][:data], :pet)
  end

  test "imports data from other fixture file for has_one association that references other file" do
    path = "test/fixtures/associations/has_one/import.exs"
    other_path = "test/fixtures/associations/has_one/import_dep.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)
    other_path = String.to_atom(other_path)

    data = EctoFixtures.condition(data)

    assert is_integer(data[other_path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:owners][:rows][:brian][:data], :pet)

    assert data[other_path][:pets][:model] == Pet
    assert data[other_path][:pets][:repo] == Base
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    path = "test/fixtures/associations/belongs_to.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)

    assert is_nil(data[path][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:pets][:rows][:boomer][:data], :owner)
  end

  test "imports data from other fixture file for belongs_to association that references other file" do
    path = "test/fixtures/associations/belongs_to/import.exs"
    other_path = "test/fixtures/associations/belongs_to/import_dep.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)
    other_path = String.to_atom(other_path)

    assert is_nil(data[path][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[path][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[path][:pets][:rows][:boomer][:data], :owner)
    assert data[other_path][:owners][:rows][:brian][:data][:name] == "Brian"

    assert data[other_path][:owners][:model] == Owner
    assert data[other_path][:owners][:repo] == Base
  end

  test "sets foreign key for has_many association properly and removes association" do
    path = "test/fixtures/associations/has_many.exs"
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

  test "imports data from other fixture file for has_many association that references other file" do
    path = "test/fixtures/associations/has_many/import.exs"
    other_path = "test/fixtures/associations/has_many/import_dep.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse

    path = String.to_atom(path)
    other_path = String.to_atom(other_path)

    assert is_nil(data[other_path][:cars][:rows][:nissan][:data][:owner_id])
    assert is_nil(data[other_path][:cars][:rows][:tesla][:data][:owner_id])
    refute is_nil(data[path][:owners][:rows][:brian][:data][:cars])

    data = EctoFixtures.condition(data)

    assert is_integer(data[other_path][:cars][:rows][:nissan][:data][:owner_id])
    assert is_integer(data[other_path][:cars][:rows][:tesla][:data][:owner_id])
    refute Map.has_key?(data[path][:owners][:rows][:brian][:data], :cars)

    assert data[other_path][:cars][:model] == Car
    assert data[other_path][:cars][:repo] == Base
  end
end
