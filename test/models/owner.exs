defmodule Owner do
  use Ecto.Model

  schema "owners" do
    field :name
    field :age, :integer

    has_one :pet, Pet
    has_many :cars, Car
  end
end
