defmodule EctoFixtures.PrimaryKeyTest do
  use ExUnit.Case
  alias EctoFixtures.PrimaryKey

  test "generates primary key value if not present for each row" do
    attributes = %{
      schema: Owner,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        name: "Brian",
        age: 36
      }
    }

    assert attributes[:columns][:id] == nil

    attributes = PrimaryKey.process(attributes, :owner)

    assert is_integer(attributes[:columns][:id])
  end

  test "supports overriden primary keys" do
    attributes = %{
      schema: Pet,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        name: "Boomer"
      }
    }

    assert attributes[:columns][:woof] == nil

    attributes = PrimaryKey.process(attributes, :pet)

    assert is_integer(attributes[:columns][:woof])
  end

  test "supports uuid for primary key" do
    attributes = %{
      schema: Car,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        color: "black"
      }
    }

    assert attributes[:columns][:id] == nil

    attributes = PrimaryKey.process(attributes, :car)

    assert is_binary(attributes[:columns][:id])
  end

  test "supports no primary key" do
    attributes = %{
      schema: Book,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        title: "Go Dog Go!"
      }
    }

    assert attributes[:columns][:id] == nil

    attributes = PrimaryKey.process(attributes, :book)

    assert attributes[:columns][:id] == nil
  end

  test "don't generate id if one already exists" do
    attributes = %{
      schema: Owner,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        id: 123,
        name: "Brian",
        age: 36
      }
    }

    assert attributes[:columns][:id] == 123

    attributes = PrimaryKey.process(attributes, :owner)

    assert attributes[:columns][:id] == 123
  end
end