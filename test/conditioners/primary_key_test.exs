defmodule EctoFixtures.Conditioners.PrimaryKeyTest do
  use ExUnit.Case

  test "generates primary key value if not present for each row" do
    data = %{foo: [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian"}},
          stephanie: %{data: %{name: "Stephanie"}}
        ]
      }
    ]}

    assert data[:foo][:owners][:rows][:brian][:data][:id] == nil
    assert data[:foo][:owners][:rows][:stephanie][:data][:id] == nil

    data = EctoFixtures.condition(data)

    assert is_integer(data[:foo][:owners][:rows][:brian][:data][:id])
    assert is_integer(data[:foo][:owners][:rows][:stephanie][:data][:id])
  end

  test "supports overriden primary keys" do
    data = %{foo: [
      pets: %{
        model: Pet,
        repo: Base,
        rows: [boomer: %{data: %{name: "Boomer"}}]
      }
    ]}

    assert data[:foo][:pets][:rows][:boomer][:data][:woof] == nil

    data = EctoFixtures.condition(data)

    assert data[:foo][:pets][:rows][:boomer][:data][:woof] != nil
    assert is_integer(data[:foo][:pets][:rows][:boomer][:data][:woof])
  end

  test "supports uuid for primary key" do
    data = %{foo: [
      cars: %{
        model: Car,
        repo: Base,
        rows: [nissan: %{data: %{color: "black"}}]
      }
    ]}

    assert data[:foo][:cars][:rows][:nissan][:data][:id] == nil

    data = EctoFixtures.condition(data)

    assert data[:foo][:cars][:rows][:nissan][:data][:id] != nil
    assert is_binary(data[:foo][:cars][:rows][:nissan][:data][:id])
  end

  test "supports no primary key" do
    data = %{foo: [
      books: %{
        model: Book,
        repo: Base,
        rows: [one: %{data: %{title: "Go Dog Go!"}}]
      }
    ]}

    assert data[:foo][:books][:rows][:one][:id] == nil

    data = EctoFixtures.condition(data)

    assert data[:foo][:books][:rows][:one][:id] == nil
  end

  test "don't generate id if one already exists" do
    data = %{foo: [
      cars: %{
        model: Car,
        repo: Base,
        rows: [nissan: %{data: %{color: "black", id: "abc"}}]
      },
      owners: %{
        model: Owner,
        repo: Base,
        rows: [brian: %{data: %{name: "Brian", id: 123}}]
      }
    ]}

    assert data[:foo][:cars][:rows][:nissan][:data][:id] == "abc"
    assert data[:foo][:owners][:rows][:brian][:data][:id] == 123

    data = EctoFixtures.condition(data)

    assert data[:foo][:cars][:rows][:nissan][:data][:id] == "abc"
    assert data[:foo][:owners][:rows][:brian][:data][:id] == 123
  end
end
