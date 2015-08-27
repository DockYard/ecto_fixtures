# EctoFixtures #

Fixtures for Ecto

[![Build Status](https://secure.travis-ci.org/dockyard/ecto_fixtures.svg?branch=master)](http://travis-ci.org/dockyard/ecto_fixtures)

## Usage ##

Fixture files should be stored in `test/fixtures/`. The format of a
fixture file is as:

```elixir
# test/fixtures/accounts.exs

accounts model: Account, repo: Repo do
  test do
    email "test@example.com"
    name "Brian Cardarella"
  end
end
```

In your test file you can access the fixture sets with the
`EctoFixtures.fixture/1` function:

```elixir
defmodule MyTestCase do
  use ExUnit.Case
  import EctoFixtures, only: [fixtures: 1]

  test "data test" do
    %{accounts: accounts} = fixtures(:accounts)

    assert accounts.test.email == "test@example.com"
  end
end
```

This data is also inserted into the database, the resulting data set
returned from `fixtures/1` is actually an `Ecto.Model`.


```elixir
defmodule MyTestCase do
  use ExUnit.Case
  import EctoFixtures, only: [fixtures: 1]

  test "database data is inserted and equal to data set" do
    %{accounts: accounts} = fixtures(:accounts)

    assert accounts.test == Repo.get(Account, accounts.test.id)
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
