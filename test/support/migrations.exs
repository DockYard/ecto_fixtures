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

    create table(:physicians) do
      add :name, :string
    end

    create table(:patients) do
      add :name, :string
    end

    create table(:appointments) do
      add :name, :string
      add :physician_id, references(:physicians)
      add :patient_id, references(:patients)
    end

    create table(:posts) do
      add :title, :string
    end

    create table(:tags) do
      add :name, :string
    end

    create table(:posts_tags) do
      add :post_id, references(:posts)
      add :tag_id, references(:tags)
    end

    create table(:post_tags) do
      add :post_id, references(:posts)
      add :tag_id, references(:tags)
    end
  end
end
