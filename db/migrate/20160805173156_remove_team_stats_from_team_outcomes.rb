class RemoveTeamStatsFromTeamOutcomes < ActiveRecord::Migration
  def change
    remove_column :team_outcomes, :team_stats_id, :integer
  end
end
