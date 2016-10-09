defmodule EctoFixtures.Conditioners.TransformTest do
  defmodule Fixtures do
    def fixture_data() do
      %{
        brian: %{
          model: Owner,
          repo: BaseRepo,
          group: :owners,
          path: "foo/bar.fixtures",
          serializer: Serializer,
          columns: %{
            name: "Brian",
            age: 36,
            pet: :boomer
          }
        },
        stephanie: %{
          model: Owner,
          repo: BaseRepo,
          group: :owners,
          path: "foo/bar.fixtures",
          columns: %{
            name: "Stephanie",
            age: 35
          }
        },
        boomer: %{
          model: Pet,
          repo: BaseRepo,
          path: "foo/bar.fixtures",
          serializer: Serializer,
          columns: %{
            name: "Boomer"
          }
        },
        nissan: %{
          model: Car,
          repo: BaseRepo,
          path: "foo/bar.fixtures",
          group: :cars,
          columns: %{
            color: "black"
          }
        },
        cars: [:nissan],
        owners: [:stephanie, :brian]
      }
    end
  end

  use EctoFixtures.Integration.Case
  use EctoFixtures.Case, with: Fixtures

  fixture :brian
  transform :brian, with: %{age: 35}
  test "can transform with a single record name and a value map", %{data: data} do
    assert data.brian.age == 35
  end

  fixtures [:brian, :stephanie]
  transform [:brian, :stephanie], with: %{age: 25}
  test "can transform with a list of records name and a value map", %{data: data} do
    assert data.brian.age == 25
    assert data.stephanie.age == 25
  end

  fixtures [:brian, :stephanie]
  transform :brian, with: %{age: 35}
  transform :stephanie, with: %{age: 36}
  test "can accumulate transforms", %{data: data} do
    assert data.brian.age == 35
    assert data.stephanie.age == 36
  end

  fixture :brian
  fixture :stephanie
  transform with: %{age: 99}
  test "can apply to all fixtures", %{data: data} do
    assert data.brian.age == 99
    assert data.stephanie.age == 99
  end

  fixtures [:brian, :stephanie]
  transform :brian, with: &__MODULE__.transform/2
  test "can take a function to transform with", %{data: data} do
    assert data.brian.age == 72
    assert data.stephanie.age == 35
  end

  def transform(_row_name, attributes) do
    age = Map.get(attributes, :age)
    Map.put(attributes, :age, age * 2)
  end
end
