defmodule Bonfire.Messages.Repo.MessagesMigrations do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Messages.Migrations

  def up, do: migrate_messages(:up)
  def down, do: migrate_messages(:down) 
end
