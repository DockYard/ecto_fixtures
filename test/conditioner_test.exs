defmodule EctoFixtures.ConditionerTest do
  use EctoFixtures.Integration.Case

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

  test "can evaluate functions to generate values" do
    path = "test/fixtures/function_call.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    path = String.to_atom(path)

    assert data[path][:owners][:rows][:brian][:data][:password_hash] == :crypto.hash(:sha, "password")
  end

  test "can evaluate Elixir types to generate values" do
    path = "test/fixtures/types.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    path = String.to_atom(path)

    assert data[path][:owners][:rows][:brian][:data][:map] == %{foo: :bar}
    assert data[path][:owners][:rows][:brian][:data][:list] == [1, 2, 3]
    assert data[path][:owners][:rows][:brian][:data][:tuple] == {1, 2, 3}
  end

  test "can inherit from other rows" do
    path = "test/fixtures/inheritance.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    path = String.to_atom(path)

    assert data[path][:owners][:rows][:brian][:data][:admin] == data[path][:owners][:rows][:stephanie][:data][:admin]
    assert data[path][:owners][:rows][:brian][:data][:viewed_profile] == data[path][:owners][:rows][:stephanie][:data][:viewed_profile]
    refute data[path][:owners][:rows][:brian][:data][:name] == data[path][:owners][:rows][:stephanie][:data][:name]

    refute data[path][:owners][:rows][:brian][:data][:admin] == data[path][:other_owners][:rows][:thomas][:data][:admin]
    assert data[path][:owners][:rows][:brian][:data][:viewed_profile] == data[path][:other_owners][:rows][:thomas][:data][:viewed_profile]
    refute data[path][:owners][:rows][:brian][:data][:name] == data[path][:other_owners][:rows][:thomas][:data][:name]
  end

  test "can override the values in the fixture file with optional map" do
    data = EctoFixtures.fixtures(:override, %{
      owners: %{
        one: %{
          name: "Stephanie",
        }
      }
    })

    assert data.owners.one.name == "Stephanie"
  end
end
