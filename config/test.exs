use Mix.Config

config :ecto_fixtures, BaseRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ecto_fixtures_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  size: 1,
  ownership_timeout: 1_000_000_000
