defmodule EctoFixtures.InsertionTest do
  use EctoFixtures.Integration.Case
  import EctoFixtures, only: [fixtures: 1, fixtures: 2]

  test "properly inserts fixtures into the database" do
    fixtures(:insert_1)

    cars = BaseRepo.all(Car)
    nissan = cars |> Enum.find(fn(car) -> car.color == "black" end)
    tesla = cars |> Enum.find(fn(car) -> car.color == "red" end)
    toyota = cars |> Enum.find(fn(car) -> car.color == "white" end)

    owners = BaseRepo.all(Owner)
    brian = owners |> Enum.find(fn(owner) -> owner.name == "Brian" end)
    stephanie = owners |> Enum.find(fn(owner) -> owner.name == "Stephanie" end)

    pets = BaseRepo.all(Pet)
    boomer = pets |> Enum.find(fn(pet) -> pet.name == "Boomer" end)

    assert nissan.owner_id == brian.id
    assert tesla.owner_id == stephanie.id
    assert toyota.owner_id == stephanie.id

    assert boomer.owner_id == brian.id
  end

  test "does not insert rows tagged with `virtual: true`" do
    fixtures(:insert_2)

    owners = BaseRepo.all(Owner)

    assert length(owners) == 0
  end

  test "does not insert any rows when `insert: false` is passed to `fixtures/2" do
    %{cars: cars, owners: owners, pets: pets} = fixtures(:insert_1, insert: false)

    assert length(BaseRepo.all(Car)) == 0
    assert %Car{} = cars.nissan
    assert cars.nissan.color == "black"
    assert cars.nissan.owner_id == owners.brian.id
    assert %Car{} = cars.tesla
    assert cars.tesla.color == "red"
    assert cars.tesla.owner_id == owners.stephanie.id
    assert %Car{} = cars.toyota
    assert cars.toyota.color == "white"
    assert cars.toyota.owner_id == owners.stephanie.id

    assert length(BaseRepo.all(Owner)) == 0
    assert %Owner{} = owners.brian
    assert owners.brian.name == "Brian"
    assert %Owner{} = owners.stephanie
    assert owners.stephanie.name == "Stephanie"

    assert length(BaseRepo.all(Pet)) == 0
    assert %Pet{} = pets.boomer
    assert pets.boomer.name == "Boomer"
    assert pets.boomer.owner_id == owners.brian.id
  end
end
