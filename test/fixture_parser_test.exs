defmodule FixturesTest do
  use ExUnit.Case
  import Fixtures

  test "parses single table and single row and single column into map" do
    map = File.read!("test/fixtures/single_table_single_row_single_column.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{brian: %{name: "Brian"}}
      }
    }
  end

  test "parses single table and single row and multiple columns into map" do
    map = File.read!("test/fixtures/single_table_single_row_multiple_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{brian: %{name: "Brian", age: 35}}
      }
    }
  end

  test "parses single table and multiple rows and single columns into map" do
    map = File.read!("test/fixtures/single_table_multiple_rows_single_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{
          brian: %{name: "Brian"},
          stephanie: %{name: "Stephanie"}
        }
      }
    }
  end

  test "parses single table and multiple rows and multiple columns into map" do
    map = File.read!("test/fixtures/single_table_multiple_rows_multiple_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{
          brian: %{name: "Brian", age: 35},
          stephanie: %{name: "Stephanie", age: 34}
        }
      }
    }
  end

  test "parses multiple tables and single rows and single columns into map" do
    map = File.read!("test/fixtures/multiple_tables_single_rows_single_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{brian: %{name: "Brian"}}
      },
      pets: %{
        model: Pet,
        repo: Base, 
        rows: %{boomer: %{name: "Boomer"}}
      }
    }
  end

  test "parses multiple tables and single rows and multiple columns into map" do
    map = File.read!("test/fixtures/multiple_tables_single_rows_multiple_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{brian: %{name: "Brian", age: 35}}
      },
      pets: %{
        model: Pet,
        repo: Base, 
        rows: %{boomer: %{name: "Boomer", age: 2}}
      }
    }
  end

  test "parses multiple tables and multiple rows and single columns into map" do
    map = File.read!("test/fixtures/multiple_tables_multiple_rows_single_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{
          brian: %{name: "Brian"},
          stephanie: %{name: "Stephanie"}
        }
      },
      pets: %{
        model: Pet,
        repo: Base, 
        rows: %{
          boomer: %{name: "Boomer"},
          wiley: %{name: "Wiley"}
        }
      }
    }
  end

  test "parses multiple tables and multiple rows and multiple columns into map" do
    map = File.read!("test/fixtures/multiple_tables_multiple_rows_multiple_columns.exs")
    |> Fixtures.parse
    assert map == %{
      owners: %{
        model: Owner,
        repo: Base, 
        rows: %{
          brian: %{name: "Brian", age: 35},
          stephanie: %{name: "Stephanie", age: 34}
        }
      },
      pets: %{
        model: Pet,
        repo: Base, 
        rows: %{
          boomer: %{name: "Boomer", age: 2},
          wiley: %{name: "Wiley", age: 12}
        }
      }
    }
  end
end
