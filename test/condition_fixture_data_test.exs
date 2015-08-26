defmodule ConditionFixtureDataTest do
  use ExUnit.Case

  test "generates primary key value if not present for each row" do
    data = %{
      owners: %{
        model: Owner,
        repo: Base,
        rows: %{
          brian: %{name: "Brian"},
          stephanie: %{name: "Stephanie"}
        }
      }
    }

    assert data.owners.rows.brian[:id] == nil
    assert data.owners.rows.stephanie[:id] == nil

    data = Fixtures.condition(data)

    assert is_integer(data.owners.rows.brian[:id])
    assert is_integer(data.owners.rows.stephanie[:id])
  end

  test "supports overriden primary keys" do
    data = %{
      pets: %{
        model: Pet,
        repo: Base,
        rows: %{boomer: %{name: "Boomer"}}
      }
    }

    assert data.pets.rows.boomer[:woof] == nil

    data = Fixtures.condition(data)

    assert data.pets.rows.boomer[:woof] != nil
    assert is_integer(data.pets.rows.boomer[:woof])
  end

  test "supports uuid for primary key" do
    data = %{
      cars: %{
        model: Car,
        repo: Base,
        rows: %{nissan: %{color: "black"}}
      }
    }

    assert data.cars.rows.nissan[:id] == nil

    data = Fixtures.condition(data)

    assert data.cars.rows.nissan[:id] != nil
    assert is_binary(data.cars.rows.nissan[:id])
  end

  test "don't generate id if one already exists" do
    data = %{
      cars: %{
        model: Car,
        repo: Base,
        rows: %{nissan: %{color: "black", id: "abc"}}
      },
      owners: %{
        model: Owner,
        repo: Base,
        rows: %{brian: %{name: "Brian", id: 123}}
      }
    }

    assert data.cars.rows.nissan[:id] == "abc"
    assert data.owners.rows.brian[:id] == 123

    data = Fixtures.condition(data)

    assert data.cars.rows.nissan[:id] == "abc"
    assert data.owners.rows.brian[:id] == 123
  end

  test "sets foreign key for has_one association properly and removes association" do
    data = Fixtures.read("test/fixtures/associations_has_one.exs")

    assert is_nil(data.pets.rows.boomer[:owner_id])

    data = Fixtures.condition(data)

    assert is_integer(data.pets.rows.boomer[:owner_id])
    refute Map.has_key?(data.owners.rows.brian, :pet)
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    data = Fixtures.read("test/fixtures/associations_belongs_to.exs")

    assert is_nil(data.pets.rows.boomer[:owner_id])

    data = Fixtures.condition(data)

    assert is_integer(data.pets.rows.boomer[:owner_id])
    refute Map.has_key?(data.pets.rows.boomer, :owner)
  end

  test "sets foreign key for has_many association properly and removes association" do
    data = Fixtures.read("test/fixtures/associations_has_many.exs")

    assert is_nil(data.cars.rows.nissan[:owner_id])
    assert is_nil(data.cars.rows.tesla[:owner_id])
    refute is_nil(data.owners.rows.brian.cars)

    data = Fixtures.condition(data)

    assert is_integer(data.cars.rows.nissan[:owner_id])
    assert is_integer(data.cars.rows.tesla[:owner_id])
    refute Map.has_key?(data.owners.rows.brian, :cars)
  end
end
