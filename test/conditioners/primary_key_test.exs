defmodule EctoFixtures.Conditioners.PrimaryKeyTest do
  use ExUnit.Case

  test "generates primary key value if not present for each row" do
    acc = %{
      owner: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          name: "Brian",
          age: 36
        }
      }
    }

    assert acc[:owner][:columns][:id] == nil

    acc = EctoFixtures.Conditioners.PrimaryKey.process(acc, :owner)

    assert is_integer(acc[:owner][:columns][:id])
  end

  test "supports overriden primary keys" do
    acc = %{
      pet: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          name: "Boomer"
        }
      }
    }

    assert acc[:pet][:columns][:woof] == nil

    acc = EctoFixtures.Conditioners.PrimaryKey.process(acc, :pet)

    assert is_integer(acc[:pet][:columns][:woof])
  end

  test "supports uuid for primary key" do
    acc = %{
      car: %{
        model: Car,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          color: "black"
        }
      }
    }

    assert acc[:car][:columns][:id] == nil

    acc = EctoFixtures.Conditioners.PrimaryKey.process(acc, :car)

    assert is_binary(acc[:car][:columns][:id])
  end

  test "supports no primary key" do
    acc = %{
      book: %{
        model: Book,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          title: "Go Dog Go!"
        }
      }
    }

    assert acc[:book][:columns][:id] == nil

    acc = EctoFixtures.Conditioners.PrimaryKey.process(acc, :book)

    assert acc[:book][:columns][:id] == nil
  end

  test "don't generate id if one already exists" do
    acc = %{
      owner: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 123,
          name: "Brian",
          age: 36
        }
      }
    }

    assert acc[:owner][:columns][:id] == 123

    acc = EctoFixtures.Conditioners.PrimaryKey.process(acc, :owner)

    assert acc[:owner][:columns][:id] == 123
  end
end
