defmodule EctoFixtures.Conditioners.FunctionCallTest do
  use ExUnit.Case

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
end
