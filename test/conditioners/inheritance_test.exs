defmodule EctoFixtures.Conditioners.InheritanceTest do
  use ExUnit.Case

  test "can inherit from other reduced rows" do
    acc = %{
      brian: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        inherits: :owner_admin,
        columns: %{
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
      owner_admin: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Default Admin",
          admin: true
        }
      }
    }

    refute Map.has_key?(acc[:brian][:columns], :admin)
    assert acc[:brian][:columns][:name] == "Brian"

    acc = EctoFixtures.Conditioners.Inheritance.process(acc, :brian)

    assert acc[:brian][:columns][:admin] == true
    assert acc[:brian][:columns][:name] == "Brian"
    refute Map.has_key?(acc[:brian][:columns], :id)
  end

  test "can inherit from other rows" do
    acc = %{
      brian: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        inherits: :owner_admin,
        columns: %{
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
      __data__: %{
        owner_admin: %{
          model: Owner,
          repo: Base,
          path: "foo/bar.fixtures",
          columns: %{
            id: 1,
            name: "Default Admin",
            admin: true
          }
        }
      }
    }

    refute Map.has_key?(acc[:brian][:columns], :admin)
    assert acc[:brian][:columns][:name] == "Brian"

    acc = EctoFixtures.Conditioners.Inheritance.process(acc, :brian)

    assert acc[:brian][:columns][:admin] == true
    assert acc[:brian][:columns][:name] == "Brian"
    refute Map.has_key?(acc[:brian][:columns], :id)
  end
end
