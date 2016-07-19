defmodule EctoFixtures.InsertionTest do
  use EctoFixtures.Integration.Case
  import EctoFixtures, only: [create_acc: 1]

  @data %{
    nissan: %{
      model: Car,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        color: "black",
        owner: :brian
      }
    },
    tesla: %{
      model: Car,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        color: "red"
      }
    },
    toyota: %{
      model: Car,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        color: "white"
      }
    },
    brian: %{
      model: Owner,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        name: "Brian",
        pet: :boomer
      }
    },
    stephanie: %{
      model: Owner,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        name: "Stephanie",
        cars: [:tesla, :toyota]
      }
    },
    boomer: %{
      model: Pet,
      repo: BaseRepo,
      path: "foo/bar.fixture",
      columns: %{
        name: "Boomer",
      }
    }
  }

  test "properly inserts fixtures into the database" do
    @data
    |> create_acc()
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

  test "does not insert rows tagged with `virtual: true`" do
    data = %{
      brian: %{
        model: Owner,
        repo: BaseRepo,
        virtual: true,
        columns: %{
          name: "Brian"
        }
      }
    }

    create_acc(data)
    |> EctoFixtures.Reducer.process([[:nissan, :tesla, :toyota, :brian, :stephanie, :boomer]])
    |> EctoFixtures.Insertion.process([])

    owners = BaseRepo.all(Owner)

    assert length(owners) == 0
  end

  test "does not insert any rows when `insert: false` is used" do
    %{nissan: nissan, tesla: tesla, toyota: toyota, brian: brian, stephanie: stephanie, boomer: boomer} =
      @data
      |> create_acc()
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
        model: Post,
        repo: BaseRepo,
        columns: %{
          title: "Test Title",
          tag: :bar
        }
      },
      bar: %{
        model: Tag,
        repo: BaseRepo,
        columns: %{
          name: "Bar Tag"
        }
      }
    }

    result =
      data
      |> create_acc()
      |> EctoFixtures.Reducer.process([[:foo]])
      |> EctoFixtures.Insertion.process([])

    assert BaseRepo.preload(result.foo, :tag).tag == result.bar
  end

  test "inserts has_many through relationships in correct order" do
    data = %{
      foo: %{
        model: Post,
        repo: BaseRepo,
        columns: %{
          title: "Test Title",
          tags: [:bar, :baz]
        }
      },
      bar: %{
        model: Tag,
        repo: BaseRepo,
        columns: %{
          name: "Bar Tag"
        }
      },
      baz: %{
        model: Tag,
        repo: BaseRepo,
        columns: %{
          name: "Baz Tag"
        }
      }
    }

    result =
      data
      |> create_acc()
      |> EctoFixtures.Reducer.process([[:foo]])
      |> EctoFixtures.Insertion.process([])

    post = BaseRepo.preload(result.foo, :tags)

    assert Enum.member?(post.tags, result.bar)
    assert Enum.member?(post.tags, result.baz)
  end

  test "inserts from deeply nested associations" do
    data = %{
      invoice_1: %{
        model: Invoice,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_1: %{
        model: Property,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_2: %{
        model: Property,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      },
      owner_1: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      owner_2: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      renter_1: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      renter_2: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      }
    }

    data
    |> create_acc()
    |> EctoFixtures.Reducer.process([[:invoice_1]])
    |> EctoFixtures.Insertion.process([])
  end

  test "inserts from deeply nested associations with passively references assciation" do
    data = %{
      payment_1: %{
        model: Payment,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          invoice: :invoice_1,
          payee: :owner_1,
          payer: :render_1
        }
      },
      invoice_1: %{
        model: Invoice,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          property: :property_1,
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_1: %{
        model: Property,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          owner: :owner_1,
          renter: :renter_1
        }
      },
      property_2: %{
        model: Property,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{
          owner: :owner_2,
          render: :renter_2
        }
      },
      owner_1: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      owner_2: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      renter_1: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      },
      renter_2: %{
        model: User,
        repo: BaseRepo,
        path: "foo/bar.fixtures",
        columns: %{ }
      }
    }

    data
    |> create_acc()
    |> EctoFixtures.Reducer.process([[:invoice_1]])
    |> EctoFixtures.Insertion.process([])
  end
end
