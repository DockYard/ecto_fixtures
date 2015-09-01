defmodule EctoFixtures.ParserTest do
  use ExUnit.Case

  test "parses single table and single row and single column into list" do
    list = File.read!("test/fixtures/single_table_single_row_single_column.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [brian: %{data: %{name: "Brian"}}]
      }
    ]
  end

  test "parses single table and single row and multiple columns into list" do
    list = File.read!("test/fixtures/single_table_single_row_multiple_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [brian: %{data: %{name: "Brian", age: 35}}]
      }
    ]
  end

  test "parses single table and multiple rows and single columns into list" do
    list = File.read!("test/fixtures/single_table_multiple_rows_single_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian"}},
          stephanie: %{data: %{name: "Stephanie"}}
        ]
      }
    ]
  end

  test "parses single table and multiple rows and multiple columns into list" do
    list = File.read!("test/fixtures/single_table_multiple_rows_multiple_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian", age: 35}},
          stephanie: %{data: %{name: "Stephanie", age: 34}}
        ]
      }
    ]
  end

  test "parses multiple tables and single rows and single columns into list" do
    list = File.read!("test/fixtures/multiple_tables_single_rows_single_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [brian: %{data: %{name: "Brian"}}]
      },
      pets: %{
        model: Pet,
        repo: Base,
        rows: [boomer: %{data: %{name: "Boomer"}}]
      }
    ]
  end

  test "parses multiple tables and single rows and multiple columns into list" do
    list = File.read!("test/fixtures/multiple_tables_single_rows_multiple_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [brian: %{data: %{name: "Brian", age: 35}}]
      },
      pets: %{
        model: Pet,
        repo: Base,
        rows: [boomer: %{data: %{name: "Boomer", age: 2}}]
      }
    ]
  end

  test "parses multiple tables and multiple rows and single columns into list" do
    list = File.read!("test/fixtures/multiple_tables_multiple_rows_single_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian"}},
          stephanie: %{data: %{name: "Stephanie"}}
        ]
      },
      pets: %{
        model: Pet,
        repo: Base,
        rows: [
          boomer: %{data: %{name: "Boomer"}},
          wiley: %{data: %{name: "Wiley"}}
        ]
      }
    ]
  end

  test "parses multiple tables and multiple rows and multiple columns into list" do
    list = File.read!("test/fixtures/multiple_tables_multiple_rows_multiple_columns.exs")
    |> EctoFixtures.parse
    assert list == [
      owners: %{
        model: Owner,
        repo: Base,
        rows: [
          brian: %{data: %{name: "Brian", age: 35}},
          stephanie: %{data: %{name: "Stephanie", age: 34}}
        ]
      },
      pets: %{
        model: Pet,
        repo: Base,
        rows: [
          boomer: %{data: %{name: "Boomer", age: 2}},
          wiley: %{data: %{name: "Wiley", age: 12}}
        ]
      }
    ]
  end
end
