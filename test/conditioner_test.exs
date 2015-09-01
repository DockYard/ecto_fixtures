defmodule EctoFixtures.ConditionerTest do
  use ExUnit.Case

  test "generates primary key value if not present for each row" do
    data = [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian"}},
          stephanie: %{data: %{name: "Stephanie"}}
        ]
      }
    ]

    assert data[:owners][:rows][:brian][:data][:id] == nil
    assert data[:owners][:rows][:stephanie][:data][:id] == nil

    data = EctoFixtures.condition(data)

    assert is_integer(data[:owners][:rows][:brian][:data][:id])
    assert is_integer(data[:owners][:rows][:stephanie][:data][:id])
  end

  test "supports overriden primary keys" do
    data = [
      pets: %{
        model: Pet,
        repo: Base,
        rows: [boomer: %{data: %{name: "Boomer"}}]
      }
    ]

    assert data[:pets][:rows][:boomer][:data][:woof] == nil

    data = EctoFixtures.condition(data)

    assert data[:pets][:rows][:boomer][:data][:woof] != nil
    assert is_integer(data[:pets][:rows][:boomer][:data][:woof])
  end

  test "supports uuid for primary key" do
    data = [
      cars: %{
        model: Car,
        repo: Base,
        rows: [nissan: %{data: %{color: "black"}}]
      }
    ]

    assert data[:cars][:rows][:nissan][:data][:id] == nil

    data = EctoFixtures.condition(data)

    assert data[:cars][:rows][:nissan][:data][:id] != nil
    assert is_binary(data[:cars][:rows][:nissan][:data][:id])
  end

  test "don't generate id if one already exists" do
    data = [
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
    ]

    assert data[:cars][:rows][:nissan][:data][:id] == "abc"
    assert data[:owners][:rows][:brian][:data][:id] == 123

    data = EctoFixtures.condition(data)

    assert data[:cars][:rows][:nissan][:data][:id] == "abc"
    assert data[:owners][:rows][:brian][:data][:id] == 123
  end

  test "sets foreign key for has_one association properly and removes association" do
    data = EctoFixtures.read("test/fixtures/associations_has_one.exs")
    |> EctoFixtures.parse

    assert is_nil(data[:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[:owners][:rows][:brian][:data], :pet)
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    data = EctoFixtures.read("test/fixtures/associations_belongs_to.exs")
    |> EctoFixtures.parse

    assert is_nil(data[:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[:pets][:rows][:boomer][:data], :owner)
  end

  test "sets foreign key for has_many association properly and removes association" do
    data = EctoFixtures.read("test/fixtures/associations_has_many.exs")
    |> EctoFixtures.parse

    assert is_nil(data[:cars][:rows][:nissan][:data][:owner_id])
    assert is_nil(data[:cars][:rows][:tesla][:data][:owner_id])
    refute is_nil(data[:owners][:rows][:brian][:data][:cars])

    data = EctoFixtures.condition(data)

    assert is_integer(data[:cars][:rows][:nissan][:data][:owner_id])
    assert is_integer(data[:cars][:rows][:tesla][:data][:owner_id])
    refute Map.has_key?(data[:owners][:rows][:brian][:data], :cars)
  end

  test "can evaluate functions to generate values" do
    data = EctoFixtures.read("test/fixtures/function_call.exs")
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert data[:owners][:rows][:brian][:data][:password_hash] == :crypto.hash(:sha, "password")
  end

  test "can evaluate Elixir types to generate values" do
    data = EctoFixtures.read("test/fixtures/types.exs")
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert data[:owners][:rows][:brian][:data][:map] == %{foo: :bar}
    assert data[:owners][:rows][:brian][:data][:list] == [1, 2, 3]
    assert data[:owners][:rows][:brian][:data][:tuple] == {1, 2, 3}
  end

  test "can inherit from other rows" do
    data = EctoFixtures.read("test/fixtures/inheritance.exs")
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    assert data[:owners][:rows][:brian][:data][:admin] == data[:owners][:rows][:stephanie][:data][:admin]
    assert data[:owners][:rows][:brian][:data][:viewed_profile] == data[:owners][:rows][:stephanie][:data][:viewed_profile]
    refute data[:owners][:rows][:brian][:data][:name] == data[:owners][:rows][:stephanie][:data][:name]

    refute data[:owners][:rows][:brian][:data][:admin] == data[:other_owners][:rows][:thomas][:data][:admin]
    assert data[:owners][:rows][:brian][:data][:viewed_profile] == data[:other_owners][:rows][:thomas][:data][:viewed_profile]
    refute data[:owners][:rows][:brian][:data][:name] == data[:other_owners][:rows][:thomas][:data][:name]
  end
end
