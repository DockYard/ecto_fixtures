defmodule EctoFixtures.NewParserTest do
  use ExUnit.Case

  @tmp_path Path.join(System.tmp_dir(), "bar.fixtures")

  test "parses rows and columns into map" do
    create_fixture("""
      @repo Base
      @model Owner

      owner1 do
        name "Brian"
        age 36
      end

      @model Pet

      pet1 do
        name "Boomer"
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Boomer"
        }
      }
    }

    assert actual == expected
  end

  test "can parse empty rows" do
    create_fixture("""
      @model Pet
      @repo Base

      pet1 do
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{}
      }
    }

    assert actual == expected
  end

  test "when repo is missing raise" do
    msg = """
    No @repo defined in `#{@tmp_path}` for `pet1`.
    You can fix this by adding the repo module attribute to your fixture file:

        @repo MyApp.Repo

    Just make sure you set the value to the actual repo module.
    """

    create_fixture("""
    @model Pet

    pet1 do
    end
    """)

    assert_raise EctoFixtures.MissingRepoError, msg, fn ->
      EctoFixtures.Parser.process(%{}, @tmp_path)
    end
  end

  test "when model is missing raise" do
    msg = """
    No @model defined in `#{@tmp_path}` for `pet1`.
    You can fix this by adding the model module attribute to your fixture file:

        @model MyApp.User

    Just make sure you set the value to the actual model module.
    """

    create_fixture("""
    @repo Base

    pet1 do
    end
    """)

    assert_raise EctoFixtures.MissingModelError, msg, fn ->
      EctoFixtures.Parser.process(%{}, @tmp_path)
    end
  end

  test "raises when redefining a named row in the same file" do
    msg = """
    You are attempting to redefine `pet1`.

    The fixture `pet1` already exists and was defined in `#{@tmp_path}` but
    there was an attempt to redefine it in the file `#{@tmp_path}`.

    You cannot have duplicate fixture names. Each fixture name must be unique across all fixture files.
    """

    create_fixture("""
    @repo Base
    @model Pet

    pet1 do
    end

    pet1 do
    end
    """)

    assert_raise EctoFixtures.FixtureNameCollisionError, msg, fn ->
      EctoFixtures.Parser.process(%{}, @tmp_path)
    end
  end

  test "raises when redefining a named row from another file" do
    msg = """
    You are attempting to redefine `pet1`.

    The fixture `pet1` already exists and was defined in `foo/baz.fixtures` but
    there was an attempt to redefine it in the file `#{@tmp_path}`.

    You cannot have duplicate fixture names. Each fixture name must be unique across all fixture files.
    """

    acc = %{
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/baz.fixtures",
        columns: %{}
      }
    }

    create_fixture("""
    @repo Base
    @model Pet

    pet1 do
    end
    """)

    assert_raise EctoFixtures.FixtureNameCollisionError, msg, fn ->
      EctoFixtures.Parser.process(acc, @tmp_path)
    end
  end

  test "can group" do
    create_fixture("""
      @repo Base
      @model Owner
      @group :owners
      @group :mammals

      owner1 do
        name "Brian"
        age 36
      end

      @model Pet
      @group :pets
      @group :mammals

      pet1 do
        name "Boomer"
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Boomer"
        }
      },
      mammals: [:owner1, :pet1],
      pets: [:pet1],
      owners: [:owner1]
    }

    assert actual == expected
  end

  test "group names cannot conflict with existing fixture name" do
    acc = %{
      pet1: %{
        model: Pet,
        repo: Base,
        path: "foo/baz.fixtures",
        columns: %{}
      }
    }

    create_fixture("""
      @repo Base
      @model Pet
      @group :pet1

      pet2 do
        name "Boomer"
      end
      """)

    msg = """
    The group name `pet1` defined in `#{@tmp_path}` is conflicting with the
    fixture name `pet1` defined in `foo/baz.fixtures`. Please choose a different name.
    """

    assert_raise EctoFixtures.GroupNameFixtureNameCollisionError, msg, fn ->
      EctoFixtures.Parser.process(acc, @tmp_path)
    end
  end

  test "fixture name cannot conflict with existing group name" do
    acc = %{
      pet2: %{
        model: Pet,
        repo: Base,
        path: "foo/baz.fixtures",
        columns: %{}
      },
      pet1: [:pet2]
    }

    create_fixture("""
      @repo Base
      @model Pet

      pet1 do
        name "Boomer"
      end
      """)

    msg = """
    The fixture name `pet1` defined in `#{@tmp_path}` is conflicting with the
    group name `pet1`. Please choose a different name.
    """

    assert_raise EctoFixtures.GroupNameFixtureNameCollisionError, msg, fn ->
      EctoFixtures.Parser.process(acc, @tmp_path)
    end
  end

  test "will parse and eval functions into generated values" do
    create_fixture("""
      @repo Base
      @model Owner

      owner do
        name "Brian"
        password_hash :crypto.hash(:sha, "password")
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian",
          password_hash: :crypto.hash(:sha, "password")
        }
      }
    }

    assert actual == expected
  end

  test "will parse and eval types properly" do
    create_fixture("""
      @repo Base
      @model Owner

      owner do
        map %{foo: :bar}
        list [1, 2, 3]
        tuple {1, 2, 3}
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          map: %{foo: :bar},
          list: [1, 2, 3],
          tuple: {1, 2, 3}
        }
      }
    }

    assert actual == expected
  end

  test "can declare a row as `virtual`" do
    create_fixture("""
      @repo Base
      @model Owner
      @virtual

      owner1 do
        name "Brian"
        age 36
      end

      @model Pet

      pet1 do
        name "Boomer"
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        virtual: true,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Boomer"
        }
      }
    }

    assert actual == expected
  end

  test "can declare a row to inherit from" do
    create_fixture("""
      @repo Base
      @model Owner
      @inherits :other_owner

      owner1 do
        name "Brian"
        age 36
      end

      @model Pet

      pet1 do
        name "Boomer"
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        inherits: :other_owner,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Boomer"
        }
      }
    }

    assert actual == expected
  end

  test "can declare a serializer" do
    create_fixture("""
      @repo Base
      @model Owner
      @serializer Serializer

      owner1 do
        name "Brian"
        age 36
      end

      owner2 do
        name "Stephanie"
        age 35
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        serializer: Serializer,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      owner2: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        serializer: Serializer,
        columns: %{
          name: "Stephanie",
          age: 35
        }
      }
    }

    assert actual == expected
  end

  test "serializer clears if a new @model is declared" do
    create_fixture("""
      @repo Base
      @model Owner
      @serializer Serializer

      owner1 do
        name "Brian"
        age 36
      end

      @model Pet

      pet1 do
        name "Boomer"
      end
      """)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        serializer: Serializer,
        columns: %{
          name: "Brian",
          age: 36
        }
      },
      pet1: %{
        model: Pet,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Boomer"
        }
      }
    }

    assert actual == expected
  end

  defp create_fixture(content) do
    File.write!(@tmp_path, content)
  end
end
