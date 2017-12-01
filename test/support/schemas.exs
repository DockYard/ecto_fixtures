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

defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title

    has_many :posts_tags, PostsTag
    has_many :tags, through: [:posts_tags, :tag]

    has_one :post_tag, PostTag
    has_one :tag, through: [:post_tag, :tag], inverse_of: :post
  end
end

defmodule PostsTag do
  use Ecto.Schema

  schema "posts_tags" do
    belongs_to :post, Post
    belongs_to :tag, Tag
  end
end

defmodule PostTag do
  use Ecto.Schema

  schema "post_tags" do
    belongs_to :post, Post
    belongs_to :tag, Tag
  end
end

defmodule Tag do
  use Ecto.Schema

  schema "tags" do
    field :name

    has_many :posts_tags, PostsTag
    has_many :posts, through: [:posts_tags, :post]

    has_one :post_tag, PostTag
    has_one :post, through: [:post_tag, :post]
  end
end

defmodule Physician do
  use Ecto.Schema

  schema "physicians" do
    field :name

    has_many :appointments, Appointment
    has_many :patients, through: [:appointments, :patient]
  end
end

defmodule Patient do
  use Ecto.Schema

  schema "patients" do
    field :name

    has_many :appointments, Appointment
    has_many :physicians, through: [:appointments, :physician]
  end
end

defmodule Appointment do
  use Ecto.Schema

  schema "appointments" do
    field :name

    belongs_to :physician, Physician
    belongs_to :patient, Patient
  end
end

defmodule User do
  use Ecto.Schema

  schema "users" do
  end
end

defmodule Property do
  use Ecto.Schema

  schema "properties" do
    belongs_to :owner, User
    belongs_to :renter, User
  end
end

defmodule Invoice do
  use Ecto.Schema

  schema "invoices" do
    belongs_to :property, Property
    belongs_to :owner, User
    belongs_to :renter, User
  end
end

defmodule Payment do
  use Ecto.Schema

  schema "payments" do
    belongs_to :invoice, Invoice
    belongs_to :payee, User
    belongs_to :payer, User
  end
end

defmodule Order do
  use Ecto.Schema

  schema "orders" do
    field :cost, :integer
  end
end
