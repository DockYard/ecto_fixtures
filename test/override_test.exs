defmodule EctoFixtures.OverrideTest do
  use EctoFixtures.Integration.Case
  import EctoFixtures, only: [fixtures: 2]

  @tag timeout: 1_000_000_000
  test "can override the values in the fixture file with optional map" do
    data = fixtures(:override, %{
      owners: %{
        one: %{
          name: "Stephanie",
        }
      }
    })

    assert data.owners.one.name == "Stephanie"
  end
end
