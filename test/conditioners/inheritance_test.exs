defmodule EctoFixtures.Conditioners.InheritanceTest do
  use ExUnit.Case

  test "can inherit from other rows" do
    path = "test/fixtures/inheritance.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    path = String.to_atom(path)

    assert data[path][:owners][:rows][:brian][:data][:admin] == data[path][:owners][:rows][:stephanie][:data][:admin]
    assert data[path][:owners][:rows][:brian][:data][:viewed_profile] == data[path][:owners][:rows][:stephanie][:data][:viewed_profile]
    refute data[path][:owners][:rows][:brian][:data][:name] == data[path][:owners][:rows][:stephanie][:data][:name]
    refute data[path][:owners][:rows][:brian][:data][:id] == data[path][:owners][:rows][:stephanie][:data][:id]

    refute data[path][:owners][:rows][:brian][:data][:admin] == data[path][:other_owners][:rows][:thomas][:data][:admin]
    assert data[path][:owners][:rows][:brian][:data][:viewed_profile] == data[path][:other_owners][:rows][:thomas][:data][:viewed_profile]
    refute data[path][:owners][:rows][:brian][:data][:name] == data[path][:other_owners][:rows][:thomas][:data][:name]
    refute data[path][:owners][:rows][:brian][:data][:id] == data[path][:other_owners][:rows][:thomas][:data][:id]
  end

  test "can inherit from other fixture files" do
    path = "test/fixtures/inheritance_fixture.exs"
    data = EctoFixtures.read(path)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    path = String.to_atom(path)

    assert data[path][:owners][:rows][:non_admin][:data][:admin] == false
    assert data[path][:owners][:rows][:non_admin][:data][:name] == "Thomas"
    assert data[path][:owners][:rows][:non_admin][:data][:viewed_profile] == true
  end
end
