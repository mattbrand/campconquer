class RemoveTeamStatsFromTeamOutcomes < ActiveRecord::Migration
  def change
    remove_column :outcomes, :team_stats_id, :integer
  rescue PG::UndefinedColumn, ActiveRecord::StatementInvalid
    # dunno how this column got out of sync
  end
end
