defmodule EctoFixtures.Mixfile do
  use Mix.Project

  def project do
    [app: :ecto_fixtures,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :uuid]]
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
      {:ecto, "> 0.0.0", only: :test},
      {:postgrex, "> 0.0.0", only: :test},
      {:uuid, "~> 1.0"}
    ]
  end
end
