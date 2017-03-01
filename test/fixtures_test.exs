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

    fixture :one, %{
      name: "One"
    }

    fixture :two, %{
      name: "Two"
    }
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
          name: "One"
        }
      },
      two: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.OwnerFixtures,
        serializers: [admin: AdminOwnerView, default: OwnerView],
        groups: [:owners],
        columns: %{
          name: "Two"
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

      fixture :one, %{
        name: "One"
      }
    end

    expected = %{
      one: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.AOwnerFixtures,
        groups: [:owners],
        columns: %{
          name: "One"
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

      fixture :one, %{
        name: "One"
      }
    end

    expected = %{
      one: %{
        repos: [admin: AdminRepo, default: BaseRepo],
        schema: Owner,
        mod: EctoFixtures.FixturesTest.BOwnerFixtures,
        serializers: [admin: AdminOwnerView, default: OwnerView],
        columns: %{
          name: "One"
        }
      }
    }

    assert BOwnerFixtures.data() == expected
  end

  test "raises error when attempting to redefine existing fixture" do
    try do
      defmodule COwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner

        fixture :one, %{
          name: "One"
        }

        fixture :one, %{
          name: "Two"
        }
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.FixturesTest.COwnerFixtures fixture :one already declared"
    end
  end

  test "raises an error when attempting to use a fixture name already set as a group name" do
    try do
      defmodule DOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        group :one

        fixture :one, %{
          name: "One"
        }
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.FixturesTest.DOwnerFixtures attempting to use :one as a fixture name but it is already claimed as the group name"
    end
  end

  test "raises an error when attempting to use a group name that a fixture has already claimed" do
    try do
      defmodule DOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner

        fixture :one, %{
          name: "One"
        }

        group :one
      end

      raise "should not hit this raise"
    rescue
      error in [ArgumentError] ->
        assert error.message == "EctoFixtures.FixturesTest.DOwnerFixtures attempting to use :one as a group name but it is already claimed by a fixture"
    end
  end

  test "can take multiple groups" do
    defmodule EOwnerFixtures do
      use EctoFixtures

      repo BaseRepo
      schema Owner
      groups [:one, :two]

      fixture :brian, %{
        name: "Brian"
      }
    end

    expected = %{
      brian: %{
        repos: [default: BaseRepo],
        schema: Owner,
        mod: EOwnerFixtures,
        groups: [:one, :two],
        columns: %{
          name: "Brian"
        }
      }
    }

    assert EOwnerFixtures.data() == expected
  end

  test "raises error when non-list passed to &groups/1" do
    try do
      defmodule FOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        groups :one

        fixture :brian, %{
          name: "Brian"
        }
      end
    rescue
      error in [ArgumentError] ->
        assert error.message == "you attempted to pass :one to &groups/1 but it only accepts lists. Perhaps you need to use &group/1 instead?"
    end
  end

  test "raises error when list passed to &group/1" do
    try do
      defmodule FOwnerFixtures do
        use EctoFixtures

        repo BaseRepo
        schema Owner
        group [:one, :two]

        fixture :brian, %{
          name: "Brian"
        }
      end
    rescue
      error in [ArgumentError] ->
        assert error.message == "you attempted to pass [:one, :two] to &group/1 but it does not accept lists. Perhaps you need to use &groups/1 instead?"
    end
  end
end
