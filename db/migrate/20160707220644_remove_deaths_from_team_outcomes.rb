class RemoveDeathsFromTeamOutcomes < ActiveRecord::Migration
  def change
    remove_column :team_outcomes, :deaths
    rename_column :team_outcomes, :captures, :pickups
  end
end
