defmodule EctoFixtures.AssociationsTest do
  use ExUnit.Case
  alias EctoFixtures.{Associations, Dag}

  test "sets foreign key for has_one association properly and removes association" do
    vertices = [{:brian, %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      }},
      {:boomer, %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer"
        }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    assert is_nil(Dag.get_in(graph, :boomer, [:columns, :owner_id]))

    graph = Associations.process(:brian, graph)

    assert Dag.get_in(graph, :boomer, [:columns, :owner_id]) == 1
    refute Map.has_key?(Dag.get_in(graph, :brian, [:columns]), :pet)
  end

  test "will not go into infinite loop with loaded associations in the graph" do
    vertices = [{:brian, %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          pet: :boomer
        }
      }},
      {:boomer, %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    assert is_nil(Dag.get_in(graph, :boomer, [:columns, :owner_id]))

    graph = Associations.process(:brian, graph)

    assert Dag.get_in(graph, :boomer, [:columns, :owner_id]) == 1
    refute Map.has_key?(Dag.get_in(graph, :brian, [:columns]), :pet)
  end

  test "sets foreign key for has_one through association properly and removes association" do
    vertices = [{:test_post, %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tag: :test_tag
        }
      }},
      {:test_tag, %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Test Tag",
          post: :test_post
        }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    through_row_name = :"test_post-1--test_tag-2--post_tag"

    refute Map.has_key?(graph.vertices, through_row_name)
    refute Map.has_key?(graph.vertices, :"test_tag-2--test_post-1--post_tag")
    assert Map.has_key?(Dag.get_in(graph, :test_post, [:columns]), :tag)

    graph = Associations.process(:test_post, graph)
    graph = Associations.process(:test_tag, graph)

    assert graph.vertices[through_row_name].value[:columns][:post_id] == 1
    assert graph.vertices[through_row_name].value[:columns][:tag_id] == 2
    refute Map.has_key?(graph.vertices, :"test_tag-2--test_post-1--post_tag")
    refute is_nil(Dag.get_in(graph, through_row_name, [:columns, :id]))
    refute Map.has_key?(graph.vertices[:test_post].value[:columns], :tag)
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    vertices = [{:brian, %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
        }
      }},
      {:boomer, %{
        schema: Pet,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Boomer",
          owner: :brian
        }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    assert is_nil(graph.vertices[:boomer].value[:columns][:owner_id])

    graph = Associations.process(:boomer, graph)

    assert graph.vertices[:boomer].value[:columns][:owner_id] == 1
    refute Map.has_key?(graph.vertices[:brian].value[:columns], :pet)
  end

  test "sets foreign key for has_many association properly and removes association" do
    vertices = [{:brian, %{
        schema: Owner,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Brian",
          age: 36,
          cars: [:nissan, :tesla]
        }
      }},
      {:nissan, %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          color: "black"
        }
      }},
      {:tesla, %{
        schema: Car,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          color: "red"
        }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    assert is_nil(graph.vertices[:nissan].value[:columns][:owner_id])
    assert is_nil(graph.vertices[:tesla].value[:columns][:owner_id])
    refute is_nil(graph.vertices[:brian].value[:columns][:cars])

    graph = Associations.process(:brian, graph)

    assert graph.vertices[:nissan].value[:columns][:owner_id] == 1
    assert graph.vertices[:tesla].value[:columns][:owner_id] == 1
    refute Map.has_key?(graph.vertices[:brian].value[:columns], :cars)
  end

  test "sets foreign key for has_many through association properly and removes association" do
    vertices = [{:test_post, %{
        schema: Post,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          title: "Test Title",
          tags: [:test_tag_1, :test_tag_2]
        }
      }},
      {:test_tag_1, %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 1,
          name: "Test Tag 1",
          posts: [:test_post]
        }
      }},
      {:test_tag_2, %{
        schema: Tag,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          id: 2,
          name: "Test Tag 2",
          posts: [:test_post]
        }
      }}]

    through_row_name_1 = :"test_post-1--test_tag_1-1--posts_tags"
    through_row_name_2 = :"test_post-1--test_tag_2-2--posts_tags"

    graph = Dag.add_vertices(%Dag{}, vertices)

    refute Map.has_key?(graph.vertices, through_row_name_1)
    refute Map.has_key?(graph.vertices, through_row_name_2)
    refute Map.has_key?(graph.vertices, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(graph.vertices, :"test_tag_2-2--test_post-1--posts_tags")
    assert Map.has_key?(graph.vertices[:test_post].value[:columns], :tags)

    graph = Associations.process(:test_post, graph)
    graph = Associations.process(:test_tag_1, graph)
    graph = Associations.process(:test_tag_2, graph)

    assert graph.vertices[through_row_name_1].value[:columns][:post_id] == 1
    assert graph.vertices[through_row_name_1].value[:columns][:tag_id] == 1

    assert graph.vertices[through_row_name_2].value[:columns][:post_id] == 1
    assert graph.vertices[through_row_name_2].value[:columns][:tag_id] == 2

    refute Map.has_key?(graph.vertices, :"test_tag_1-1--test_post-1--posts_tags")
    refute Map.has_key?(graph.vertices, :"test_tag_2-2--test_post-1--posts_tags")

    refute Map.has_key?(graph.vertices[:test_post].value[:columns], :tags)
  end

  test "dag ordering continues for deeply nested assocations" do
    vertices = [{:invoice_1, %{
        schema: Invoice,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      }},
      {:property_1, %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      }},
      {:property_2, %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      }},
      {:owner_1, %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }},
      {:owner_2, %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }},
      {:renter_1, %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }},
      {:renter_2, %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }}]

    graph = Dag.add_vertices(%Dag{}, vertices)

    graph = Enum.reduce(Map.keys(graph.vertices), graph, fn(label, graph) ->
      Associations.process(label, graph)  
    end)

    invoice_in_edges = graph.vertices[:invoice_1].in_edges
    property_in_edges = graph.vertices[:property_1].in_edges

    assert Enum.member?(invoice_in_edges, :owner_1)
    assert Enum.member?(invoice_in_edges, :renter_1)
    assert Enum.member?(invoice_in_edges, :property_1)

    assert Enum.member?(property_in_edges, :owner_1)
    assert Enum.member?(property_in_edges, :renter_1)
  end
end