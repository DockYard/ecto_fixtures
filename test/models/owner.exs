defmodule Owner do
  use Ecto.Model

  schema "owners" do
    field :name
    field :age, :integer
  end
end
