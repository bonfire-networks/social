defmodule Bonfire.Poll.Repo.Migrations.ImportPoll do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Poll.Question.Migration
  import Bonfire.Poll.Vote.Migration
  import Bonfire.Poll.Choice.Migration

  import Needle.Migration

  def up do
    migrate_question()
    migrate_choice()
    migrate_vote()
  end

  def down do
    migrate_vote()
    migrate_choice()
    migrate_question()
  end
end
