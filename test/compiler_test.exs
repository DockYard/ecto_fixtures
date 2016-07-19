defmodule CompileTimeTest do
  use ExUnit.Case

  defmodule Fixtures do
    use EctoFixtures
  end

  test "files are read and parsed from given path" do
    expected = %{
      brian: %{
        model: Owner,
        repo: BaseRepo,
        path: "test/fixtures/owners.fixtures",
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      stephanie: %{
        model: Owner,
        repo: BaseRepo,
        path: "test/fixtures/owners.fixtures",
        columns: %{
          name: "Stephanie",
          age: 35
        }
      },
      boomer: %{
        model: Pet,
        repo: BaseRepo,
        path: "test/fixtures/pets.fixtures",
        columns: %{
          name: "Boomer"
        }
      },
      nissan: %{
        model: Car,
        repo: BaseRepo,
        path: "test/fixtures/foo/cars.fixtures",
        columns: %{
          color: "black"
        }
      },
      cars: [:nissan],
      owners: [:brian, :stephanie]
    }

    actual = Fixtures.fixture_data()

    assert actual == expected
  end

  test "generates __ecto_fixtures_recompile__? function" do
    refute Fixtures.__ecto_fixtures_recompile__?
  end
end
