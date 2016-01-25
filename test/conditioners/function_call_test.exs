defmodule EctoFixtures.Conditioners.FunctionCallTest do
  use ExUnit.Case

  test "can evaluate functions to generate values" do
    source = "test/fixtures/function_call.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    source = String.to_atom(source)

    assert data[source][:owners][:rows][:brian][:data][:password_hash] == :crypto.hash(:sha, "password")
  end

  test "can evaluate Elixir types to generate values" do
    source = "test/fixtures/types.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse
    |> EctoFixtures.condition

    source = String.to_atom(source)

    assert data[source][:owners][:rows][:brian][:data][:map] == %{foo: :bar}
    assert data[source][:owners][:rows][:brian][:data][:list] == [1, 2, 3]
    assert data[source][:owners][:rows][:brian][:data][:tuple] == {1, 2, 3}
  end
end
