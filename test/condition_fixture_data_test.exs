defmodule ConditionFixtureDataTest do
  use ExUnit.Case
  import Fixtures

  test "injects generated UUID for primary key is one is not present for each row" do
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

    assert data.owners.rows.brian[:id] != nil
    assert is_integer(data.owners.rows.brian[:id])
    assert data.owners.rows.stephanie[:id] != nil
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
end
