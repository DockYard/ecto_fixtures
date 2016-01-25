defmodule EctoFixtures.Conditioners.InheritanceTest do
  use ExUnit.Case

  test "can inherit from other rows" do
    source = "test/fixtures/inheritance.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    source = String.to_atom(source)

    assert data[source][:owners][:rows][:brian][:data][:admin] == data[source][:owners][:rows][:stephanie][:data][:admin]
    assert data[source][:owners][:rows][:brian][:data][:viewed_profile] == data[source][:owners][:rows][:stephanie][:data][:viewed_profile]
    refute data[source][:owners][:rows][:brian][:data][:name] == data[source][:owners][:rows][:stephanie][:data][:name]
    refute data[source][:owners][:rows][:brian][:data][:id] == data[source][:owners][:rows][:stephanie][:data][:id]

    refute data[source][:owners][:rows][:brian][:data][:admin] == data[source][:other_owners][:rows][:thomas][:data][:admin]
    assert data[source][:owners][:rows][:brian][:data][:viewed_profile] == data[source][:other_owners][:rows][:thomas][:data][:viewed_profile]
    refute data[source][:owners][:rows][:brian][:data][:name] == data[source][:other_owners][:rows][:thomas][:data][:name]
    refute data[source][:owners][:rows][:brian][:data][:id] == data[source][:other_owners][:rows][:thomas][:data][:id]
  end

  test "can inherit from other fixture files" do
    source = "test/fixtures/inheritance_fixture.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    source = String.to_atom(source)

    assert data[source][:owners][:rows][:non_admin][:data][:admin] == false
    assert data[source][:owners][:rows][:non_admin][:data][:name] == "Thomas"
    assert data[source][:owners][:rows][:non_admin][:data][:viewed_profile] == true
  end
end
