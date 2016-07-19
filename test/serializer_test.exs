defmodule EctoFixtures.SerializerTest do
  use EctoFixtures.Integration.Case

  defmodule Serializer do
    def format(data, opts) do
      map =
        data
        |> Map.from_struct()
        |> Enum.into(%{}, fn
          {key, value} when is_number(value) -> {key, value}
          {key, value} when is_binary(value) -> {key, String.upcase(value)}
          {key, value} -> {key, value}
        end)
        |> Enum.into(%{}, fn({key, value}) ->
          case Map.fetch(opts, key) do
            {:ok, value} -> {key, value}
            :error -> {key, value}
          end
        end)

      struct(data.__struct__, map)
    end
  end

  defmodule Fixtures do
    def serialize(data, serializer, opts \\ %{}) do
      serializer.format(data, opts)
    end

    def fixture_data() do
      %{
        owner_1: %{
          model: Owner,
          repo: BaseRepo,
          path: "foo/bar.fixtures",
          serializer: Serializer,
          columns: %{
            name: "Brian",
            age: 36,
            pet: :pet_1
          }
        },
        owner_2: %{
          model: Owner,
          repo: BaseRepo,
          path: "foo/bar.fixtures",
          columns: %{
            name: "Stephanie",
            age: 35
          }
        },
        pet_1: %{
          model: Pet,
          repo: BaseRepo,
          path: "foo/bar.fixtures",
          serializer: Serializer,
          columns: %{
            name: "Boomer",
            owner: :owner_1
          }
        }
      }
    end
  end

  def serialize_opts(record) do
    Map.put(record, :name, "#{record.name}-foobar")
  end

  use EctoFixtures.Case, with: Fixtures

  fixture :owner_1
  serialize
  test "will run fixture data through serializer", %{data: data} do
    assert data.owner_1.name == "BRIAN"
  end

  fixture :owner_1
  test "will not run fixture data through serializer if not requested", %{data: data} do
    assert data.owner_1.name == "Brian"
  end

  fixtures [:owner_1, :owner_2, :pet_1]
  serialize
  test "will only run fixture data through serializer if serializer is provided", %{data: data} do
    assert data.owner_1.name == "BRIAN"
    assert data.owner_2.name == "Stephanie"
    assert data.pet_1.name == "BOOMER"
  end

  fixture :owner_1
  serialize
  test "will serialize all child records", %{data: data} do
    assert data.owner_1.name == "BRIAN"
    assert data.pet_1.name == "BOOMER"
  end

  fixture :owner_1
  serialize only: [:owner_1]
  test "will serialize only records requested", %{data: data} do
    assert data.owner_1.name == "BRIAN"
    assert data.pet_1.name == "Boomer"
  end

  fixtures [:owner_1, :owner_2]
  serialize with: %{name: "ZOOMER"}
  test "will use serializer opts", %{data: data} do
    assert data.owner_1.name == "ZOOMER"
    assert data.pet_1.name == "ZOOMER"
  end

  # fixtures [:owner_1, :owner_2]
  # serialize with: &serialize_opts/1
  # test "will use serializer opts as a function", %{data: data} do
    # assert data.owner_1.name == "Brian-foobar"
    # assert data.pet_1.name == "Boomer-foobar"
  # end
end
