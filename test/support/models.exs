defmodule Car do
  use Ecto.Schema

  @primary_key {:id, :binary_id, []}

  schema "cars" do
    field :color
    belongs_to :owner, Owner
  end
end

defmodule Owner do
  use Ecto.Schema

  schema "owners" do
    field :name
    field :age, :integer

    has_one :pet, Pet
    has_many :cars, Car
  end
end

defmodule Pet do
  use Ecto.Schema

  @primary_key {:woof, :id, []}

  schema "pets" do
    field :name
    field :age, :integer

    belongs_to :owner, Owner, references: :id
  end
end

defmodule Book do
  use Ecto.Schema

  @primary_key false

  schema "books" do
    field :title
  end
end
