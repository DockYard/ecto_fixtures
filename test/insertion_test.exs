defmodule InsertionTest do
  use Ecto.Fixtures.Integration.Case
  import Fixtures, only: [fixtures: 1]

  @tag timeout: 30000000
  test "properly inserts fixtures into the database" do
    fixtures(:insert_1)

    cars = BaseRepo.all(Car)
    owners = BaseRepo.all(Owner)
    pets = BaseRepo.all(Pet)

    assert Enum.at(cars, 0).color == "black"
    assert Enum.at(cars, 0).owner_id == Enum.at(owners, 0).id
    assert Enum.at(cars, 1).color == "red"
    assert Enum.at(cars, 1).owner_id == Enum.at(owners, 1).id
    assert Enum.at(cars, 2).color == "white"
    assert Enum.at(cars, 2).owner_id == Enum.at(owners, 1).id

    assert Enum.at(owners, 0).name == "Brian"
    assert Enum.at(owners, 1).name == "Stephanie"

    assert Enum.at(pets, 0).name == "Boomer"
    assert Enum.at(pets, 0).owner_id == Enum.at(owners, 0).id
  end
end
