defmodule Bonfire.Social.Graph.Repo.Migrations.Import do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Social.Graph.Migrations

  def up, do: migrate_social_graph(:up)
  def down, do: migrate_social_graph(:down)
end
