defmodule Pet do
  use Ecto.Model

  schema "pets" do
    field :name
    field :age, :integer
  end
end
