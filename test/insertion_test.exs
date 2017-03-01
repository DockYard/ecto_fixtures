defmodule EctoFixtures.InsertionTest do
  use EctoFixtures.Integration.Case
  import EctoFixtures.Acc, only: [build: 1]

  @data %{
    nissan: %{
      schema: Car,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        color: "black",
        owner: :brian
      }
    },
    tesla: %{
      schema: Car,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        color: "red"
      }
    },
    toyota: %{
      schema: Car,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        color: "white"
      }
    },
    brian: %{
      schema: Owner,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        name: "Brian",
        pet: :boomer
      }
    },
    stephanie: %{
      schema: Owner,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        name: "Stephanie",
        cars: [:tesla, :toyota]
      }
    },
    boomer: %{
      schema: Pet,
      repos: [default: BaseRepo],
      mod: FooBar,
      columns: %{
        name: "Boomer",
      }
    }
  }

  test "properly inserts fixtures into the database" do
    @data
    |> build()
    |> EctoFixtures.Reducer.process([[:nissan, :tesla, :toyota, :brian, :stephanie, :boomer]])
    |> EctoFixtures.Insertion.process([])

    cars = BaseRepo.all(Car)
    nissan = cars |> Enum.find(fn(car) -> car.color == "black" end)
    tesla = cars |> Enum.find(fn(car) -> car.color == "red" end)
    toyota = cars |> Enum.find(fn(car) -> car.color == "white" end)

    owners = BaseRepo.all(Owner)
    brian = owners |> Enum.find(fn(owner) -> owner.name == "Brian" end)
    stephanie = owners |> Enum.find(fn(owner) -> owner.name == "Stephanie" end)

    pets = BaseRepo.all(Pet)
    boomer = pets |> Enum.find(fn(pet) -> pet.name == "Boomer" end)

    assert nissan.owner_id == brian.id
    assert tesla.owner_id == stephanie.id
    assert toyota.owner_id == stephanie.id

    assert boomer.owner_id == brian.id
  end

  test "does not insert any rows when `insert: false` is used" do
    %{nissan: nissan, tesla: tesla, toyota: toyota, brian: brian, stephanie: stephanie, boomer: boomer} =
      @data
      |> build()
      |> EctoFixtures.Reducer.process([[:nissan, :tesla, :toyota, :brian, :stephanie, :boomer]])
      |> EctoFixtures.Insertion.process(false)

    assert length(BaseRepo.all(Car)) == 0
    assert %Car{} = nissan
    assert nissan.color == "black"
    assert nissan.owner_id == brian.id
    assert %Car{} = tesla
    assert tesla.color == "red"
    assert tesla.owner_id == stephanie.id
    assert %Car{} = toyota
    assert toyota.color == "white"
    assert toyota.owner_id == stephanie.id

    assert length(BaseRepo.all(Owner)) == 0
    assert %Owner{} = brian
    assert brian.name == "Brian"
    assert %Owner{} = stephanie
    assert stephanie.name == "Stephanie"

    assert length(BaseRepo.all(Pet)) == 0
    assert %Pet{} = boomer
    assert boomer.name == "Boomer"
    assert boomer.owner_id == brian.id
  end

  test "inserts has_one through relationships in correct order" do
    data = %{
      foo: %{
        schema: Post,
        repos: [default: BaseRepo],
        columns: %{
          title: "Test Title",
          tag: :bar
        }
      },
      bar: %{
        schema: Tag,
        repos: [default: BaseRepo],
        columns: %{
          name: "Bar Tag"
        }
      }
    }

    result =
      data
      |> build()
      |> EctoFixtures.Reducer.process([[:foo]])
      |> EctoFixtures.Insertion.process([])

    assert BaseRepo.preload(result.foo, :tag).tag == result.bar
  end

  test "inserts has_many through relationships in correct order" do
    data = %{
      foo: %{
        schema: Post,
        repos: [default: BaseRepo],
        columns: %{
          title: "Test Title",
          tags: [:bar, :baz]
        }
      },
      bar: %{
        schema: Tag,
        repos: [default: BaseRepo],
        columns: %{
          name: "Bar Tag"
        }
      },
      baz: %{
        schema: Tag,
        repos: [default: BaseRepo],
        columns: %{
          name: "Baz Tag"
        }
      }
    }

    result =
      data
      |> build()
      |> EctoFixtures.Reducer.process([[:foo]])
      |> EctoFixtures.Insertion.process([])

    post = BaseRepo.preload(result.foo, :tags)

    assert Enum.member?(post.tags, result.bar)
    assert Enum.member?(post.tags, result.baz)
  end

  test "inserts from deeply nested associations" do
    data = %{
      invoice_1: %{
        schema: Invoice,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_1: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_2: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      },
      owner_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      owner_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }
    }

    data
    |> build()
    |> EctoFixtures.Reducer.process([[:invoice_1]])
    |> EctoFixtures.Insertion.process([])
  end

  test "inserts from deeply nested associations with passively references assciation" do
    data = %{
      payment_1: %{
        schema: Payment,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          invoice: :invoice_1,
          payee: :owner_1,
          payer: :render_1
        }
      },
      invoice_1: %{
        schema: Invoice,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_1: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_2: %{
        schema: Property,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      },
      owner_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      owner_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_1: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      },
      renter_2: %{
        schema: User,
        repos: [default: BaseRepo],
        mod: FooBar,
        columns: %{ }
      }
    }

    data
    |> build()
    |> EctoFixtures.Reducer.process([[:invoice_1]])
    |> EctoFixtures.Insertion.process([])
  end
end
