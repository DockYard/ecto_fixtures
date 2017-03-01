defmodule EctoFixtures.Conditioners.AssociationsTest do
  use ExUnit.Case
  import EctoFixtures.Dag, only: [create: 0]

  test "sets foreign key for has_one association properly and removes association" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer"
        }
      }
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "will not go into infinite loop with loaded associations in the accumulator" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "sets foreign key for has_one through association properly and removes association" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      test_post: %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tag: :test_tag
        }
      },
      test_tag: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Test Tag",
          post: :test_post
        }
      }
    }

    through_row_name = :"test_post-1--test_tag-2--post_tag"

    refute Map.has_key?(acc, through_row_name)
    refute Map.has_key?(acc, :"test_tag-2--test_post-1--post_tag")
    assert Map.has_key?(acc[:test_post][:columns], :tag)

    acc =
      EctoFixtures.Conditioners.Associations.process(acc, :test_post)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag)

    assert acc[through_row_name][:columns][:post_id] == 1
    assert acc[through_row_name][:columns][:tag_id] == 2
    refute Map.has_key?(acc, :"test_tag-2--test_post-1--post_tag")
    refute is_nil(acc[through_row_name][:columns][:id])
    refute Map.has_key?(acc[:test_post][:columns], :tag)
  end

  test "loads has_one association not found in the accumulator from the data object" do
    data = %{
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer"
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "does not go into infinite loop when loading association not found in the accumulator from the data object" do
    data = %{
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      },
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "loads has_one through association not found in the accumulator from the data object" do
    data = %{
      test_tag: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Test Tag",
          post: :test_post
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      test_post: %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tag: :test_tag
        }
      }
    }

    through_row_name = :"test_post-1--test_tag-1--post_tag"

    refute Map.has_key?(acc, through_row_name)
    refute Map.has_key?(acc, :"test_tag-1--test_post-1--post_tag")
    assert Map.has_key?(acc[:test_post][:columns], :tag)
    refute acc[:test_tag]

    acc =
      EctoFixtures.Conditioners.Associations.process(acc, :test_post)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag)

    assert acc[through_row_name][:columns][:post_id] == 1
    assert acc[through_row_name][:columns][:tag_id] == 1
    refute Map.has_key?(acc, :"test_tag-1--test_post-1--post_tag")
    refute Map.has_key?(acc[:test_post][:columns], :tag)
    assert acc[:test_tag]
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
        }
      },
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :boomer)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "loads belongs_to association not found in the accumulator from the data object" do
    data = %{
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      boomer: %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }
    }

    assert is_nil(acc[:boomer][:columns][:owner_id])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :boomer)

    assert acc[:boomer][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :pet)
  end

  test "sets foreign key for has_many association properly and removes association" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          cars: [:nissan, :tesla]
        }
      },
      nissan: %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          color: "black"
        }
      },
      tesla: %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          color: "red"
        }
      }
    }

    assert is_nil(acc[:nissan][:columns][:owner_id])
    assert is_nil(acc[:tesla][:columns][:owner_id])
    refute is_nil(acc[:brian][:columns][:cars])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:nissan][:columns][:owner_id] == 1
    assert acc[:tesla][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :cars)
  end

  test "loads has_many association not found in the accumulator from the data object" do
    data = %{
      nissan: %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          color: "black"
        }
      },
      tesla: %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          color: "red"
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      brian: %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          cars: [:nissan, :tesla]
        }
      },
    }

    refute Map.has_key?(acc, :nissan)
    refute Map.has_key?(acc, :tesla)
    refute is_nil(acc[:brian][:columns][:cars])

    acc = EctoFixtures.Conditioners.Associations.process(acc, :brian)

    assert acc[:nissan][:columns][:owner_id] == 1
    assert acc[:tesla][:columns][:owner_id] == 1
    refute Map.has_key?(acc[:brian][:columns], :cars)
  end

  test "sets foreign key for has_many through association properly and removes association" do
    acc = %{
      __dag__: create(),
      __data__: %{},
      test_post: %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tags: [:test_tag_1, :test_tag_2]
        }
      },
      test_tag_1: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Test Tag 1",
          posts: [:test_post]
        }
      },
      test_tag_2: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Test Tag 2",
          posts: [:test_post]
        }
      }
    }

    through_row_name_1 = :"test_post-1--test_tag_1-1--posts_tags"
    through_row_name_2 = :"test_post-1--test_tag_2-2--posts_tags"

    refute Map.has_key?(acc, through_row_name_1)
    refute Map.has_key?(acc, through_row_name_2)
    refute Map.has_key?(acc, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(acc, :"test_tag_2-2--test_post-1--posts_tags")
    assert Map.has_key?(acc[:test_post][:columns], :tags)

    acc =
      acc
      |> EctoFixtures.Conditioners.Associations.process(:test_post)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag_1)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag_2)

    assert acc[through_row_name_1][:columns][:post_id] == 1
    assert acc[through_row_name_1][:columns][:tag_id] == 1

    assert acc[through_row_name_2][:columns][:post_id] == 1
    assert acc[through_row_name_2][:columns][:tag_id] == 2

    refute Map.has_key?(acc, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(acc, :"test_tag_2-2--test_post-1--posts_tags")

    refute Map.has_key?(acc[:test_post][:columns], :tags)
  end

  test "loads has_many through association not found in the accumulator from the data object" do
    data = %{
      test_tag_1: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Test Tag 1",
          posts: [:test_post]
        }
      },
      test_tag_2: %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Test Tag 2",
          posts: [:test_post]
        }
      }
    }

    acc = %{
      __dag__: create(),
      __data__: data,
      test_post: %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tags: [:test_tag_1, :test_tag_2]
        }
      }
    }

    through_row_name_1 = :"test_post-1--test_tag_1-1--posts_tags"
    through_row_name_2 = :"test_post-1--test_tag_2-2--posts_tags"

    refute Map.has_key?(acc, through_row_name_1)
    refute Map.has_key?(acc, through_row_name_2)
    refute Map.has_key?(acc, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(acc, :"test_tag_2-2--test_post-1--posts_tags")
    assert Map.has_key?(acc[:test_post][:columns], :tags)

    acc =
      acc
      |> EctoFixtures.Conditioners.Associations.process(:test_post)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag_1)
      |> EctoFixtures.Conditioners.Associations.process(:test_tag_2)

    assert acc[through_row_name_1][:columns][:post_id] == 1
    assert acc[through_row_name_1][:columns][:tag_id] == 1
    refute is_nil(acc[through_row_name_1][:columns][:id])

    assert acc[through_row_name_2][:columns][:post_id] == 1
    assert acc[through_row_name_2][:columns][:tag_id] == 2
    refute is_nil(acc[through_row_name_2][:columns][:id])

    refute Map.has_key?(acc, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(acc, :"test_tag_2-2--test_post-1--posts_tags")

    refute Map.has_key?(acc[:test_post][:columns], :tags)
  end

  test "dag ordering continues for deeply nested assocations" do
    data = %{
      invoice_1: %{
        schema: Invoice,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_1: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_2: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      },
      owner_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      owner_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }
    }

    acc =
      %{__dag__: EctoFixtures.Dag.create(), __data__: data}
      |> EctoFixtures.Reducer.process([[:invoice_1]])

    dag = acc[:__dag__]

    invoice_vtx = :invoice_1
    owner_vtx = :owner_1
    renter_vtx = :renter_1
    property_vtx = :property_1

    assert :digraph.get_path(dag, owner_vtx, invoice_vtx) == [owner_vtx, invoice_vtx]
    assert :digraph.get_path(dag, renter_vtx, invoice_vtx) == [renter_vtx, invoice_vtx]
    assert :digraph.get_path(dag, property_vtx, invoice_vtx) == [property_vtx, invoice_vtx]

    assert :digraph.get_path(dag, owner_vtx, property_vtx) == [owner_vtx, property_vtx]
    assert :digraph.get_path(dag, renter_vtx, property_vtx) == [renter_vtx, property_vtx]
  end
end
