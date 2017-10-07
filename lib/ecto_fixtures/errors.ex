defmodule EctoFixtures.MissingRepoError do
  defexception [:message]
end

defmodule EctoFixtures.MissingModelError do
  defexception [:message]
end

defmodule EctoFixtures.FixtureNameCollisionError do
  defexception [:message]
end

defmodule EctoFixtures.GroupNameFixtureNameCollisionError do
  defexception [:message]
end
