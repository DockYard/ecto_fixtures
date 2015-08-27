defmodule Ecto.Fixtures.NormalizerTest do
  use Ecto.Fixtures.Integration.Case
  import Ecto.Fixtures, only: [fixtures: 1]

  test "normalized data allows proper access" do
    %{cars: cars, owners: owners, pets: pets} = fixtures(:insert_1)

    assert cars.nissan.color == "black"
    assert cars.nissan.owner_id == owners.brian.id
    assert cars.tesla.color == "red"
    assert cars.tesla.owner_id == owners.stephanie.id
    assert cars.toyota.color == "white"
    assert cars.toyota.owner_id == owners.stephanie.id

    assert owners.brian.name == "Brian"
    assert owners.stephanie.name == "Stephanie"

    assert pets.boomer.name == "Boomer"
    assert pets.boomer.owner_id == owners.brian.id
  end

  test "normalized data removes model, repo, and rows" do
    %{cars: cars, owners: owners, pets: pets} = fixtures(:insert_1)

    refute Map.has_key?(cars, :model)
    refute Map.has_key?(cars, :repo)
    refute Map.has_key?(cars, :rows)

    refute Map.has_key?(owners, :model)
    refute Map.has_key?(owners, :repo)
    refute Map.has_key?(owners, :rows)

    refute Map.has_key?(pets, :model)
    refute Map.has_key?(pets, :repo)
    refute Map.has_key?(pets, :rows)
  end
end
