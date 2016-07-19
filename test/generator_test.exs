defmodule EctoFixtures.GeneratorTest do
  use ExUnit.Case

  @tmp_path Path.join(System.tmp_dir(), "bar.fixtures")

  test "will generate 3 rows with dynamic index data injected" do
    create_fixture(~S/
      @repo Base
      @model Owner
      @generate 3
      @enum car: ["nissan", "toyota"]
      @enum color: ["red", "blue", "black", "yello"]
      @var town: "Boston"

      owner do
        name "Brian #{var!(i)}"
        age var!(i)
        car var!(car)
        color var!(color)
        town var!(town)
      end

      stephanie do
        name "Stephanie"
        town var!(town)
      end
      /)

    actual = EctoFixtures.Parser.process(%{}, @tmp_path)

    expected = %{
      owner_1: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian 1",
          age: 1,
          car: "nissan",
          color: "red",
          town: "Boston"
        }
      },
      owner_2: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian 2",
          age: 2,
          car: "toyota",
          color: "blue",
          town: "Boston"
        }
      },
      owner_3: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Brian 3",
          age: 3,
          car: "nissan",
          color: "black",
          town: "Boston"
        }
      },
      stephanie: %{
        model: Owner,
        repo: Base,
        path: @tmp_path,
        columns: %{
          name: "Stephanie",
          town: "Boston"
        }
      }
    }

    assert actual == expected
  end

  defp create_fixture(content) do
    File.write!(@tmp_path, content)
  end
end
