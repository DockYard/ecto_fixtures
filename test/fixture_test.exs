defmodule FixturesTest do
  use ExUnit.Case
  import Fixtures

  test "parses single table and single row into map" do
    map = Fixtures.parse("test/fixtures/single_table_single_row.exs")
    assert map == %{
      owners: %{
        brian: %{name: "Brian", age: 35}
      }
    }
  end

  test "parses single table and multiple rows into map" do
    map = Fixtures.parse("test/fixtures/single_table_multiple_rows.exs")
    assert map == %{
      owners: %{
        brian: %{name: "Brian", age: 35},
        stephanie: %{name: "Stephanie", age: 34}
      }
    }
  end

  test "parses multiple tables and single row into map" do
    map = Fixtures.parse("test/fixtures/multiple_tables_single_row.exs")
    assert map == %{
      owners: %{
        brian: %{name: "Brian", age: 35}
      },
      pets: %{
        boomer: %{name: "Boomer", age: 2}
      }
    }
  end

  test "parses multiple tables and multiple rows into map" do
    map = Fixtures.parse("test/fixtures/multiple_tables_multiple_rows.exs")
    assert map == %{
      owners: %{
        brian: %{name: "Brian", age: 35},
        stephanie: %{name: "Stephanie", age: 34}
      },
      pets: %{
        boomer: %{name: "Boomer", age: 2},
        wiley: %{name: "Wiley", age: 12}
      }
    }
  end
end
