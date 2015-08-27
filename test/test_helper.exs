Logger.configure(level: :info)
ExUnit.start

Code.require_file "./support/models.exs", __DIR__
Code.require_file "./support/repo.exs", __DIR__
Code.require_file "./support/migration.exs", __DIR__

defmodule EctoFixtures.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(BaseRepo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(BaseRepo, []) end
    :ok
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(BaseRepo, [])
    :ok
  end
end

_ = Ecto.Storage.down(BaseRepo)
:ok = Ecto.Storage.up(BaseRepo)

{:ok, _pid} = BaseRepo.start_link
:ok = Ecto.Migrator.up(BaseRepo, 0, EctoFixtures.Migrations, log: false)
Process.flag(:trap_exit, true)
