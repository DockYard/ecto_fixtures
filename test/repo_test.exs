defmodule EctoFixtures.RepoTest do
  use ExUnit.Case

  alias EctoFixtures.Dag

  defmodule Fixtures.Owners do
    use EctoFixtures

    repo BaseRepo
    schema Owner

    def brian do
      %{name: "Brian", cars: [:nissan]}
    end
  end

  defmodule Fixtures.Cars do
    use EctoFixtures

    repo BaseRepo
    schema Car

    def nissan do
      %{color: "black"}
    end
  end

  test "ensure fixture repo compiles attributes" do
    defmodule CompiledFixtures do
      use EctoFixtures.Repo, with: [
        Fixtures.Owners,
        Fixtures.Cars
      ]
    end

    graph = CompiledFixtures.graph()

    values = %{
      brian: %{
        schema: Owner,
        mod: Fixtures.Owners,
        repos: [default: BaseRepo],
        columns: %{
          name: "Brian",
          id: 613173056
        }
      },
      nissan: %{
        schema: Car,
        mod: Fixtures.Cars,
        repos: [default: BaseRepo],
        columns: %{
          color: "black",
          id: "bacf0c40-6efb-5ed8-a4ba-204b153749ca",
          owner_id: 613173056
        }
      }
    }

    assert Dag.get_vertex(graph, :brian).value == values[:brian]
    assert Dag.get_vertex(graph, :nissan).value == values[:nissan]
  end

  test "raise if another fixture name is already defined" do
    defmodule Fixtures.OtherOwners do
      use EctoFixtures

      repo BaseRepo
      schema Owner

      def brian do
        %{name: "Other Brian"}
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

  # test "extracts groups into higher level" do
  #   defmodule Fixtures.Group1 do
  #     use EctoFixtures

  #     repo BaseRepo
  #     schema Owner
  #     groups [:one, :two]

  #     def brian do
  #       %{name: "Brian"}
  #     end

  #     def stephanie do
  #       %{name: "Stephanie"}
  #     end
  #   end

  #   defmodule Fixtures.Group2 do
  #     use EctoFixtures

  #     repo BaseRepo
  #     schema Owner
  #     group :one

  #     def thomas do
  #       %{name: "Thomas"}
  #     end
  #   end

  #   defmodule GroupedFixtures do
  #     use EctoFixtures.Repo, with: [
  #       Fixtures.Group1,
  #       Fixtures.Group2
  #     ]
  #   end

  #   values = %{
  #     brian: %{
  #       repos: [default: BaseRepo],
  #       schema: Owner,
  #       mod: Fixtures.Group1,
  #       columns: %{
  #         name: "Brian",
  #         id: 613173056
  #       }
  #     },
  #     stephanie: %{
  #       repos: [default: BaseRepo],
  #       schema: Owner,
  #       mod: Fixtures.Group1,
  #       columns: %{
  #         name: "Stephanie",
  #         id: 1046141125
  #       }
  #     },
  #     thomas: %{
  #       repos: [default: BaseRepo],
  #       schema: Owner,
  #       mod: Fixtures.Group2,
  #       columns: %{
  #         name: "Thomas",
  #         id: 295706741
  #       }
  #     },
  #     one: [:brian, :stephanie, :thomas],
  #     two: [:brian, :stephanie]
  #   }

  #   graph = GroupedFixtures.graph()

  #   assert Dag.get_vertex(graph, :brian).value == values[:brian]
  #   assert Dag.get_vertex(graph, :stephanie).value == values[:stephanie]
  #   assert Dag.get_vertex(graph, :thomas).value == values[:thomas]
  #   assert Dag.get_vertex(graph, :one).value == values[:one]
  #   assert Dag.get_vertex(graph, :two).value == values[:two]
  # end
end