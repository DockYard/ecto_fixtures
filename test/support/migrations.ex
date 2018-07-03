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

    create table(:users)

    create table(:properties) do
      add :renter_id, references(:users)
      add :owner_id, references(:users)
    end

    create table(:invoices) do
      add :property_id, references(:properties)
      add :renter_id, references(:users)
      add :owner_id, references(:users)
    end

    create table(:payments) do
      add :invoice_id, references(:invoices)
      add :payee_id, references(:users)
      add :payer_id, references(:users)
    end

    create table(:orders) do
      add :cost, :integer, default: 0
    end
  end
end
