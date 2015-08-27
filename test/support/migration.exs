defmodule EctoFixtures.Migrations do
  use Ecto.Migration

  def change do
    create table(:cars, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :color, :string
      add :owner_id, :integer
    end

    create table(:owners) do
      add :name, :string
      add :age, :integer
    end

    create table(:pets, primary_key: false) do
      add :woof, :integer
      add :name, :string
      add :age, :integer
      add :owner_id, :integer
    end
  end
end
