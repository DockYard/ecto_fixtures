defmodule EctoFixtures.Conditioners.OverrideTest do
  use EctoFixtures.Integration.Case

  test "can override the values in the fixture file with optional map" do
    data = EctoFixtures.fixtures(:override, %{
      owners: %{
        one: %{
          name: "Stephanie",
        }
      }
    })

    assert data.owners.one.name == "Stephanie"
  end
end
