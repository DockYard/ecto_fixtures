# EctoFixtures #

Fixtures for Ecto

[![Build Status](https://secure.travis-ci.org/DockYard/ecto_fixtures.svg?branch=master)](http://travis-ci.org/dockyard/ecto_fixtures)

## Installation

Add `ecto_fixtures` to your `mix.exs` as a dependency.
You will likely only want it for the `test` environment:

```elixir
  {:ecto_fixtures, '~> 0.1.0', only: :test}
```

Run `mix deps.get` from the command line.

Start by creating a new `Fixtures` module.

**Note** the module file name should be `.ex` and not `.exs`.

### With a Phoenix App

If you are writing a Phoenix app the best place to put this will be
in `test/support/fixtures.ex`

```elixir
demofule MyApp.Test.Fixtures do
  use EctoFixtures
end
```

### Without a Phoenix App

If you are not using Phoenix `test/support` is still a good option but
you likely need to add `test/support` to the load paths. You can do this
by editing `mix.exs`:

In the `project` function add:

```elixir
elixirc_paths: elixirc_paths(Mix.env)
```

Then add the following two function definitions:

```elixir
defp elixirc_paths(:test), do: ["lib", "test/support"]
defp elixirc_paths(_),     do: ["lib"]
```

This will instruct Elixir that for the `test` environment files found
in `test/support` should be compiled.

## Writing your first fixture

Fixture files should be stored in `test/fixtures/`. Let's create a
user fixture at `test/fixtures/users.fixtures`

```elixir
@repo MyApp.Repo
@model MyApp.User

brian do
  name "Brian"
end

stephanie do
  name "Stephanie"
end
```

The `@repo` and `@model` values will apply to all records that follow.
We can redefine these values at any point and the records that follow
will inherit that new value:

```elixir
@repo MyApp.RepoA
@model MyApp.User

brian do
  name "Brian"
end

@repo MyApp.RepoB

stephanie do
  name "Stephanie"
end
```

For the `brian` record it will use `MyApp.RepoA` for db insertion. And
`stephanie` will use `MyApp.RepoB`. You can change the model value as
well but we recommend not mixing model types in a given fixture file, it
can get difficult to maintain.

## Using your fixtures

In your test file you can access the fixture sets with the
by tagging each test with the fixtures you want to load then
pattern matching on the `data` field for the `context` argument.

```elixir
defmodule MyTestCase do
  use ExUnit.Case
  use MyApp.Test.Fixtures

  fixtures [:brian, :stephanie]
  test "data test", %{data: data}  do
    assert data.brian.name == "Brian"
    assert data.stephanie.name == "Stephanie"
  end
end
```

This data is also inserted into the database, the resulting data set
returned from `fixtures/1` is actually an `Ecto.Model`.


```elixir
defmodule MyTestCase do
  use ExUnit.Case
  use MyApp.Test.Fixtures

  test "database data is inserted and equal to data set", %{data: data} do
    assert data.brian == Repo.get(MyApp.User, data.brian.id)
  end
end
```

Primary key values are automatically generated for you. Their value is
consistent across test runs.

### Using multiple fixtures

You can use both the `fixtures` and `fixture` macros before each test
as many times as you wish to enable the formatting and grouping you
prefer:

```elixir
defmodule MyTestCase do
  use ExUnit.Case
  use MyApp.Test.Fixtures

  fixture :brian
  fixtures [:boomer, :wiley]
  fixture :stephanie
  test "let's do this", %{data: data} do
    ...
  end
end
```

## Serialization

If you are testing an API and that API is returning serialized
data. It can be very verbose to have to grab the fixture data, serialize
it, and assert it against the payload data. Having to repeat this
process over many tests can lead to a lot of repeated code. Let's see
how EctoFixtures makes this much easier.

### Define the serializer in the fixture file

In each fixture file you can define a serializer module that will be
used

EctoFixtures will coalesce all of the data for you properly and
performantly. There is no perf penalty to breaking things out in this
way.


## Avoiding Inserts

If you'd like the model structs without actually inserting into the
database pass `insert: false` to `fixtures/2`.

```elixir
defmodule MyTestCase do
  use ExUnit.Case
  import EctoFixtures, only: [fixtures: 2]

  test "database data is inserted and equal to data set" do
    fixtures(:accounts, insert: false)

    assert length(Repo.all(Account)) == 0
  end
end
```

## Optional Overrides

You can override the fixture data on a per-usage basis by passing a map
as the 2nd argument. The maps keys must correspond with the structure of
the fixture names and row names column data you wish to override.

**Note: you cannot add rows with the override. It is intended only to
mutate the fixture column data**

```elixir
defmodule MyTestCase do
  use ExUnit.Case
  import EctoFixtures, only: [fixtures: 2]

  test "data test" do
    %{accounts: accounts} = fixtures(:accounts, %{
      accounts: %{
        test: %{
          email: "other@example.com"
        }
      }
    })

    assert accounts.test.email != "test@example.com"
    assert accounts.test.email == "other@example.com"
  end
end
```

## Associations

Associations can be made between data sets, reference the data set's
name and label:

### Belongs To

```elixir
accounts model: Account, repo: Repo do
  brian do
    name "Brian"
  end
end

events model: Event, repo: Repo do
  one do
    name "First Event"
    account accounts.brian
  end
end
```

### Has One

```elixir
accounts model: Account, repo: Repo do
  brian do
    name "Brian"
    pet pets.boomer
  end
end

pets model: Pet, repo: Repo do
  boomer do
    name "Boomer"
  end
end
```

### Has Many

```elixir
accounts model: Account, repo: Repo do
  brian do
    name "Brian"
    events [events.one, events.two]
  end
end

events model: Event, repo: Repo do
  one do
    name "First Event"
  end
  two do
    name "Second Event"
  end
end
```

### Between other fixtures files

Associations can also be made between fixture files:

```elixir
# test/fixtures/accounts.exs
accounts model: Account, repo: Repo do
  brian do
    name "Brian"
    pet fixtures(:pets).pets.boomer
  end
end

# test/fixtures/pets.exs
pets model: Pet, repo: Repo do
  boomer do
    name "Boomer"
  end
end
```

### Handling Foreign Key Constraints

ecto_fixtures will determine the assocation type being made and ensure
that child records are always inserted *after* the parent record to
avoid any foreign key constraint issues, regardless of the order in
which the fixtures are loaded. 

## Inheriting Data

If you'd like to have default values inherited into other rows you can
do that with the `inherit` option on the row defintion:

```elixir
accounts model: Account, repo: Repo do
  default do
    is_admin false
  end

  brian inherits: default do
    name "Brian"
  end
end

other_accounts: Account, repo: Repo do
  stephanie inherits: accounts.default do
    name "Stephanie"
    is_admin true
  end
end
```

When inheriting from rows in the same group you can simply refer to the
row name. When referring to rows in other groups you have to refer to
the group name and table name.

You can inherit data from other fixture files as well:

```elixir
# test/fixtures/accounts.exs
accounts model: Account, repo: Repo do
  default do
    is_admin false
  end

  brian inherits: default do
    name "Brian"
  end
end

# test/fixtures/other_accounts.exs
other_accounts: Account, repo: Repo do
  stephanie inherits: fixtures(:accounts).accounts.default do
    name "Stephanie"
    is_admin true
  end
end
```

Inherited values can be overriden by defining values on the same column.

### Virtual Rows

Sometimes you may not want the row you inherit from to be inserted into
the database. In this case you must set the `virtual: true` flag for
that row:

```elixir
accounts model: Account, repo: repo do
  default virtual: true do
    is_admin false
  end
end
```

## Authors ##

* [Brian Cardarella](http://twitter.com/bcardarella)

[We are very thankful for the many contributors](https://github.com/dockyard/ecto_fixtures/graphs/contributors)

## Versioning ##

This library follows [Semantic Versioning](http://semver.org)

## Want to help? ##

Please do! We are always looking to improve this library. Please see our
[Contribution Guidelines](https://github.com/dockyard/ecto_fixtures/blob/master/CONTRIBUTING.md)
on how to properly submit issues and pull requests.

## Legal ##

[DockYard](http://dockyard.com/), Inc. &copy; 2015

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
