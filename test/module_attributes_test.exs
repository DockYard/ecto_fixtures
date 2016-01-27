defmodule EctoFixtures.ModuleAttributesTest do
  use EctoFixtures
  use EctoFixtures.Integration.Case

  # @tag fixtures: "module_attributes/owners"
  # test "support module attributes style", %{data: data} do
    # assert data.owners.brian.name == "Brian"
  # end

  @fixtures "module_attributes/owners"
  @fixtures "module_attributes/cars"
  test "can load multiple fixture files", %{data: data} do
    assert data.owners.brian.name == "Brian"
    assert data.cars.nissan.color == "black"
  end

  # @tag fixtures: ["module_attributes/owners", "module_attributes/other_owners"]
  # test "can merge data groups", %{data: data} do
    # assert data.owners.brian.name == "Brian"
    # assert data.owners.stephanie.name == "Stephanie"
  # end
end
