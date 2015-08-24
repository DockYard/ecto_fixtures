# Fixtures #

Fixtures for Elixir

[![Build Status](https://secure.travis-ci.org/dockyard/fixtures.svg?branch=master)](http://travis-ci.org/dockyard/fixtures)

## Usage ##

Fixture files should be stored in `test/fixtures/`. The format of a
fixture file is as:

```elixir
# test/fixtures/accounts.exs

accounts do
  test do
    email "test@example.com"
    name "Brian Cardarella"
  end
end
```

## Authors ##

* [Brian Cardarella](http://twitter.com/bcardarella)

[We are very thankful for the many contributors](https://github.com/dockyard/fixtures/graphs/contributors)

## Versioning ##

This library follows [Semantic Versioning](http://semver.org)

## Want to help? ##

Please do! We are always looking to improve this library. Please see our
[Contribution Guidelines](https://github.com/dockyard/fixtures/blob/master/CONTRIBUTING.md)
on how to properly submit issues and pull requests.

## Legal ##

[DockYard](http://dockyard.com/), Inc. &copy; 2015

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
