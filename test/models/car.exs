defmodule Car do
  use Ecto.Model

  @primary_key {:id, :binary_id, []}

  schema "cars" do
    field :color
  end
end
