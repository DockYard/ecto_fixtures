defmodule EctoFixtures.RepoTest do
  use ExUnit.Case

  defmodule Fixtures.Owners do
    use EctoFixtures

    repo BaseRepo
    schema Owner

    def brian do
      %{ name: "Brian" }
    end
  end

  defmodule Fixtures.Cars do
    use EctoFixtures

    repo BaseRepo
    schema Car

    def nissan do
      %{ color: "black" }
    end
  end

  test "ensure fixture repo compiles attributes" do
    defmodule CompiledFixtures do
      use EctoFixtures.Repo, with: [
        Fixtures.Owners,
        Fixtures.Cars
      ]
    end

    data = CompiledFixtures.data()

    expected = %{
      brian: %{
        schema: Owner,
        mod: Fixtures.Owners,
        repos: [default: BaseRepo],
        columns: %{
          name: "Brian"
        }
      },
      nissan: %{
        schema: Car,
        mod: Fixtures.Cars,
        repos: [default: BaseRepo],
        columns: %{
          color: "black"
        }
      }
    }

    assert data == expected
  end

  test "raise if another fixture name is already defined" do
    defmodule Fixtures.OtherOwners do
      use EctoFixtures

      repo BaseRepo
      schema Owner

      def brian do
        %{ name: "Oter Brian" }
      end
    end

    try do
      defmodule DoubleFixtures do
        use EctoFixtures.Repo, with: [
          Fixtures.Owners,
          Fixtures.OtherOwners
        ]
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.RepoTest.Fixtures.OtherOwners attempted to define fixture :brian but that fixture name is already being used in EctoFixtures.RepoTest.Fixtures.Owners"
    end
  end

  test "extracts groups into higher level" do
    defmodule Fixtures.Group1 do
      use EctoFixtures

      repo BaseRepo
      schema Owner
      groups [:one, :two]

      def brian do
        %{ name: "Brian" }
      end

      def stephanie do
        %{ name: "Stephanie" }
      end
    end

    defmodule Fixtures.Group2 do
      use EctoFixtures

      repo BaseRepo
      schema Owner
      group :one

      def thomas do
        %{ name: "Thomas" }
      end
    end

    defmodule GroupedFixtures do
      use EctoFixtures.Repo, with: [
        Fixtures.Group1,
        Fixtures.Group2
      ]
    end

    expected = %{
      brian: %{
        repos: [default: BaseRepo],
        schema: Owner,
        mod: Fixtures.Group1,
        columns: %{
          name: "Brian"
        }
      },
      stephanie: %{
        repos: [default: BaseRepo],
        schema: Owner,
        mod: Fixtures.Group1,
        columns: %{
          name: "Stephanie"
        }
      },
      thomas: %{
        repos: [default: BaseRepo],
        schema: Owner,
        mod: Fixtures.Group2,
        columns: %{
          name: "Thomas"
        }
      },
      one: [:brian, :stephanie, :thomas],
      two: [:brian, :stephanie]
    }

    assert GroupedFixtures.data() == expected
  end
end
