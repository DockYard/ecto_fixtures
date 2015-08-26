defmodule Pet do
  use Ecto.Model

  @primary_key {:woof, :id, []}
  schema "pets" do
    field :name
    field :age, :integer

    belongs_to :owner, Owner, references: :id
  end
end
