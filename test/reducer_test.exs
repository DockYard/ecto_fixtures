defmodule EctoFixtures.ReducerTest do
  use ExUnit.Case
  import EctoFixtures, only: [create_acc: 1]

  test "will.Reducer.process parsed map to given fixture name" do
    data = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      }
    }

    actual =
      create_acc(data)
      |> EctoFixtures.Reducer.process([[:owner1]])
      |> clean()

    assert actual == expected
  end

  test "will.Reducer.process parsed map to given group" do
    data = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      },
      owner2: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 2,
          name: "Stephanie",
          age: 35
        }
      },
      pet2: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
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
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    actual =
      data
      |> create_acc()
      |> EctoFixtures.Reducer.process([[:one]])
      |> clean()

    assert actual == expected
  end

  test "will.Reducer.process parsed map to given fixture names" do
    data = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      owner2: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 2,
          name: "Stephanie",
          age: 35
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    actual =
      data
      |> create_acc()
      |> EctoFixtures.Reducer.process([[:owner1, :pet1]])
      |> clean()

    assert actual == expected
  end

  test "adds vertex to the digraph for new rows taken from the data" do
    data = %{
      owner: %{
        model: Owner,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          id: 1,
          name: "Brian",
          age: 36
        }
      },
      pet: %{
        model: Pet,
        repo: Base,
        path: "foo/bar.fixtures",
        columns: %{
          woof: 1,
          name: "Boomer"
        }
      }
    }

    acc =
      data
      |> create_acc()
      |> EctoFixtures.Reducer.process([[:pet]])

    assert :digraph.vertices(acc[:__dag__]) == [:pet]
  end

  defp clean(acc) do
    acc
    |> Map.delete(:__dag__)
    |> Map.delete(:__data__)
  end
end
