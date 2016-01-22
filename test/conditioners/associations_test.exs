defmodule EctoFixtures.Conditioners.AssociationsTest do
  use ExUnit.Case

  test "sets foreign key for has_one association properly and removes association" do
    source = "test/fixtures/associations/has_one.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse()

    source = String.to_atom(source)

    assert is_nil(data[source][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[source][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[source][:owners][:rows][:brian][:data], :pet)
  end

  test "sets foreign key for has_one through association properly and removes association" do
    source = "test/fixtures/associations/has_one/through.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)

    assert is_nil(data[source][:post_tags])
    assert Map.has_key?(data[source][:posts][:rows][:foo][:data], :tag)

    data = EctoFixtures.condition(data)

    path = [source, :posts, :rows, :foo]
    inverse_path = [source, :tags, :rows, :bar]

    through_row_name =
      (Enum.join(path, "-") <> ":" <> Enum.join(inverse_path, "-"))
      |> String.to_atom()

    assert is_integer(data[source][:post_tags][:rows][through_row_name][:data][:post_id])
    assert is_integer(data[source][:post_tags][:rows][through_row_name][:data][:tag_id])
    refute Map.has_key?(data[source][:posts][:rows][:foo][:data], :tag)
  end

  test "imports data from inverse fixture file for has_one association that references inverse file" do
    source = "test/fixtures/associations/has_one/import.exs"
    inverse_source = "test/fixtures/associations/has_one/import_dep.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)
    inverse_source = String.to_atom(inverse_source)

    data = EctoFixtures.condition(data)

    assert is_integer(data[inverse_source][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[source][:owners][:rows][:brian][:data], :pet)

    assert data[inverse_source][:pets][:model] == Pet
    assert data[inverse_source][:pets][:repo] == Base
  end

  test "imports data from inverse fixture file for has_one through association that references inverse file" do
    source = "test/fixtures/associations/has_one/through/import.exs"
    inverse_source = "test/fixtures/associations/has_one/through/import_dep.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse


    source = String.to_atom(source)
    inverse_source = String.to_atom(inverse_source)

    assert is_nil(data[source][:post_tags])
    assert Map.has_key?(data[source][:posts][:rows][:foo][:data], :tag)

    data = EctoFixtures.condition(data)

    path = [source, :posts, :rows, :foo]
    inverse_path = [inverse_source, :tags, :rows, :bar]

    through_row_name =
      (Enum.join(path, "-") <> ":" <> Enum.join(inverse_path, "-"))
      |> String.to_atom()

    assert is_integer(data[source][:post_tags][:rows][through_row_name][:data][:post_id])
    assert is_integer(data[source][:post_tags][:rows][through_row_name][:data][:tag_id])
    refute Map.has_key?(data[source][:posts][:rows][:foo][:data], :tag)

    assert data[inverse_source][:tags][:model] == Tag
    assert data[inverse_source][:tags][:repo] == BaseRepo
  end

  test "sets foreign key for belongs_to association properly and removes association" do
    source = "test/fixtures/associations/belongs_to.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)

    assert is_nil(data[source][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[source][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[source][:pets][:rows][:boomer][:data], :owner)
  end

  test "imports data from inverse fixture file for belongs_to association that references inverse file" do
    source = "test/fixtures/associations/belongs_to/import.exs"
    inverse_source = "test/fixtures/associations/belongs_to/import_dep.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)
    inverse_source = String.to_atom(inverse_source)

    assert is_nil(data[source][:pets][:rows][:boomer][:data][:owner_id])

    data = EctoFixtures.condition(data)

    assert is_integer(data[source][:pets][:rows][:boomer][:data][:owner_id])
    refute Map.has_key?(data[source][:pets][:rows][:boomer][:data], :owner)
    assert data[inverse_source][:owners][:rows][:brian][:data][:name] == "Brian"

    assert data[inverse_source][:owners][:model] == Owner
    assert data[inverse_source][:owners][:repo] == Base
  end

  test "sets foreign key for has_many association properly and removes association" do
    source = "test/fixtures/associations/has_many.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)

    assert is_nil(data[source][:cars][:rows][:nissan][:data][:owner_id])
    assert is_nil(data[source][:cars][:rows][:tesla][:data][:owner_id])
    refute is_nil(data[source][:owners][:rows][:brian][:data][:cars])

    data = EctoFixtures.condition(data)

    assert is_integer(data[source][:cars][:rows][:nissan][:data][:owner_id])
    assert is_integer(data[source][:cars][:rows][:tesla][:data][:owner_id])
    refute Map.has_key?(data[source][:owners][:rows][:brian][:data], :cars)
  end

  test "imports data from inverse fixture file for has_many association that references inverse file" do
    source = "test/fixtures/associations/has_many/import.exs"
    inverse_source = "test/fixtures/associations/has_many/import_dep.exs"
    data = EctoFixtures.read(source)
    |> EctoFixtures.parse

    source = String.to_atom(source)
    inverse_source = String.to_atom(inverse_source)

    assert is_nil(data[inverse_source][:cars][:rows][:nissan][:data][:owner_id])
    assert is_nil(data[inverse_source][:cars][:rows][:tesla][:data][:owner_id])
    refute is_nil(data[source][:owners][:rows][:brian][:data][:cars])

    data = EctoFixtures.condition(data)

    assert is_integer(data[inverse_source][:cars][:rows][:nissan][:data][:owner_id])
    assert is_integer(data[inverse_source][:cars][:rows][:tesla][:data][:owner_id])
    refute Map.has_key?(data[source][:owners][:rows][:brian][:data], :cars)

    assert data[inverse_source][:cars][:model] == Car
    assert data[inverse_source][:cars][:repo] == Base
  end
end
