defmodule Bonfire.Posts.Repo.Migrations.Import do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Posts.Migrations

  def up, do: migrate_posts(:up)
  def down, do: migrate_posts(:down) 
end
