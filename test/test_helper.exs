Logger.configure(level: :info)
ExUnit.start

Code.require_file "./support/schemas.exs", __DIR__
Code.require_file "./support/repo.exs", __DIR__
Code.require_file "./support/migrations.exs", __DIR__

defmodule EctoFixtures.Integration.Case do
  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BaseRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BaseRepo, {:shared, self()})
    end

    :ok
  end
end

_   = Ecto.Adapters.Postgres.storage_down(BaseRepo.config)
:ok = Ecto.Adapters.Postgres.storage_up(BaseRepo.config)

{:ok, _pid} = BaseRepo.start_link

:ok = Ecto.Migrator.up(BaseRepo, 0, EctoFixtures.Migrations, log: false)
Ecto.Adapters.SQL.Sandbox.mode(BaseRepo, :manual)
Process.flag(:trap_exit, true)
