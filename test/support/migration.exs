defmodule EctoFixtures.Migrations do
  use Ecto.Migration

  def change do
    create table(:owners) do
      add :name, :string
      add :age, :integer
    end

    create table(:cars, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :color, :string
      add :owner_id, references(:owners)
    end

    create table(:pets, primary_key: false) do
      add :woof, :integer
      add :name, :string
      add :age, :integer
      add :owner_id, references(:owners)
    end
  end
end
