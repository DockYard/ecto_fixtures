defmodule EctoFixtures.Mixfile do
  use Mix.Project

  def project do
    [app: :ecto_fixtures,
     version: "0.0.2",
     elixir: "~> 1.3",
     name: "Ecto Fixtures",
     deps: deps(),
     package: package(),
     elixirc_paths: elixirc_paths(Mix.env),
     description: description()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :uuid, :ecto]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  def description do
    """
    Ecto Fixtures provides a simple DSL for quickly creating fixture
    data for your test suite.
    """
  end

  def package do
    [contributors: ["Brian Cardarella"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/dockyard/ecto_fixtures"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.2.0"},
      {:postgrex, "> 0.0.0", only: :test},
      {:uuid, "~> 1.0"}
    ]
  end
end
