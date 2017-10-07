defmodule EctoFixtures.MacrosTest do
  defmodule Fixtures do
    def data() do
      %{
        brian: %{
          schema: Owner,
          repos: [default: BaseRepo],
          mod: FooBar,
          serializers: [default: Serializer],
          columns: %{
            name: "Brian",
            age: 36,
            pet: :boomer
          }
        },
        stephanie: %{
          schema: Owner,
          repos: [default: BaseRepo],
          mod: FooBar,
          columns: %{
            name: "Stephanie",
            age: 35
          }
        },
        boomer: %{
          schema: Pet,
          repos: [default: BaseRepo],
          mod: FooBar,
          serializers: [default: Serializer],
          columns: %{
            name: "Boomer"
          }
        },
        nissan: %{
          schema: Car,
          repos: [default: BaseRepo],
          mod: FooBar,
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
  test "support module attributes style", %{data: data} do
    assert data.brian.name == "Brian"
  end

  fixtures [:brian, :nissan]
  test "can load multiple fixture files", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.nissan.color == "black"
  end

  fixture :brian
  fixture :nissan
  test "can load multiple fixture files accumulated", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.nissan.color == "black"
  end

  fixture :owners
  test "can load fixture a group", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.stephanie.name == "Stephanie"
  end

  fixtures [:owners, :cars]
  test "can load fixture groups", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.stephanie.name == "Stephanie"
    assert data.nissan.color == "black"
  end

  fixture :owners
  fixture :cars
  test "can load fixture groups accumulated", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.stephanie.name == "Stephanie"
    assert data.nissan.color == "black"
  end

  fixture :boomer
  fixtures [:brian, :stephanie]
  fixture :cars
  test "can mix loading types", %{data: data} do
    assert data.brian.name == "Brian"
    assert data.stephanie.name == "Stephanie"
    assert data.nissan.color == "black"
    assert data.boomer.name == "Boomer"
  end

  fixtures [:brian, :stephanie]
  fixture :cars
  insert except: [:brian, :stephanie, :boomer]
  test "options won't leak into aggregated module attributes" do
    count = BaseRepo.all(Owner) |> length()
    assert count == 0
    count = BaseRepo.all(Car) |> length()
    assert count == 1
  end
end
