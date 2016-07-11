class TeamOutcomeBelongsToOutcome < ActiveRecord::Migration
  def change
    add_column :team_outcomes, :outcome_id, :integer
    add_index :team_outcomes, :outcome_id
    remove_column :outcomes, :team_stats_id, :integer
  end
end
