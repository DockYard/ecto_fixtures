defmodule EctoFixtures.FixturesTest do
  use ExUnit.Case

  defmodule OwnerFixtures do
    use EctoFixtures

    repo BaseRepo
    repo AdminRepo, :admin
    schema Owner
    serializer OwnerView
    serializer AdminOwnerView, :admin
    group :owners

    def one do
      %{name: "One"}
    end

    def two do
      %{name: "Two"}
    end
  end

  test "fixture module compiles data" do
    expected = %{
      one: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.OwnerFixtures,
        serializers: [admin: AdminOwnerView, default: OwnerView],
        groups: [:owners],
        columns: %{
          name: "One",
          id: 664243336
        }
      },
      two: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.OwnerFixtures,
        serializers: [admin: AdminOwnerView, default: OwnerView],
        groups: [:owners],
        columns: %{
          name: "Two",
          id: 397987669
        }
      }
    }

    assert OwnerFixtures.data() == expected
  end

  test "serializers not included when empty" do
    defmodule AOwnerFixtures do
      use EctoFixtures

      repo BaseRepo
      repo AdminRepo, :admin
      schema Owner
      group :owners

      def one do
        %{name: "One"}
      end
    end

    expected = %{
      one: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.AOwnerFixtures,
        groups: [:owners],
        columns: %{
          name: "One",
          id: 664243336
        }
      }
    }

    assert AOwnerFixtures.data() == expected
  end

  test "group not included when no provided" do
    defmodule BOwnerFixtures do
      use EctoFixtures

      repo BaseRepo
      repo AdminRepo, :admin
      schema Owner
      serializer OwnerView
      serializer AdminOwnerView, :admin

      def one do
        %{name: "One"}
      end
    end

    expected = %{
      one: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.BOwnerFixtures,
        serializers: [admin: AdminOwnerView, default: OwnerView],
        columns: %{
          name: "One",
          id: 664243336
        }
      }
    }

    assert BOwnerFixtures.data() == expected
  end

  test "raises an error when attempting to use a fixture name already set as a group name" do
    try do
      defmodule DOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        group :one

        def one do
          %{name: "One"}
        end
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.FixturesTest.DOwnerFixtures attempting to use :one as a fixture name but it is already claimed as the group name"
    end
  end

  test "raises an error when attempting to use a group name that a fixture has already claimed" do
    try do
      defmodule EOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner

        def one do
          %{name: "One"}
        end

        group :one
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.FixturesTest.EOwnerFixtures attempting to use :one as a group name but it is already claimed by a fixture"
    end
  end

  test "can take multiple groups" do
    defmodule FOwnerFixtures do
      use EctoFixtures

      repo BaseRepo
      schema Owner
      groups [:one, :two]

      def brian do
        %{name: "Brian"}
      end
    end

    expected = %{
      brian: %{
        repos: [default: BaseRepo],
        schema: Owner,
        mod: FOwnerFixtures,
        groups: [:one, :two],
        columns: %{
          name: "Brian",
          id: 613173056
        }
      }
    }

    assert FOwnerFixtures.data() == expected
  end

  test "raises error when non-list passed to &groups/1" do
    try do
      defmodule GOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        groups :one

        def brian do
          %{name: "Brian"}
        end
      end
    rescue
      error in [ArgumentError] ->
        assert error.message == "you attempted to pass :one to &groups/1 but it only accepts lists. Perhaps you need to use &group/1 instead?"
    end
  end

  test "raises error when list passed to &group/1" do
    try do
      defmodule HOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        group [:one, :two]

        def brian do
          %{name: "Brian"}
        end
      end
    rescue
      error in [ArgumentError] ->
        assert error.message == "you attempted to pass [:one, :two] to &group/1 but it does not accept lists. Perhaps you need to use &groups/1 instead?"
    end
  end
end
