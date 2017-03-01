defmodule EctoFixtures.ReducerTest do
  use ExUnit.Case
  import EctoFixtures.Acc, only: [build: 1]

  test "will.Reducer.process parsed map to given fixture name" do
    data = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    expected = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      }
    }

    actual =
      build(data)
      |> EctoFixtures.Reducer.process([[:owner1]])
      |> clean()

    assert actual == expected
  end

  test "will.Reducer.process parsed map to given group" do
    data = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      },
      owner2: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Stephanie",
          age: 35
        }
      },
      pet2: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 2,
          name: "Wiley"
        }
      },
      one: [:owner1, :pet1],
      two: [:owner2, :pet1]
    }

    expected = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    actual =
      data
      |> build()
      |> EctoFixtures.Reducer.process([[:one]])
      |> clean()

    assert actual == expected
  end

  test "will.Reducer.process parsed map to given fixture names" do
    data = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      owner2: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Stephanie",
          age: 35
        }
      },
      pet1: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    expected = %{
      owner1: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    actual =
      data
      |> build()
      |> EctoFixtures.Reducer.process([[:owner1, :pet1]])
      |> clean()

    assert actual == expected
  end

  test "adds vertex to the digraph for new rows taken from the data" do
    data = %{
      owner: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    acc =
      data
      |> build()
      |> EctoFixtures.Reducer.process([[:pet]])

    assert :digraph.vertices(acc[:__dag__]) == [:pet]
  end

  defp clean(acc) do
    acc
    |> Map.delete(:__dag__)
    |> Map.delete(:__data__)
  end
end
