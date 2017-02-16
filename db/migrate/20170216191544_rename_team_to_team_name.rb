class RenameTeamToTeamName < ActiveRecord::Migration
  def change
    rename_column :pieces, :team, :team_name
    rename_column :players, :team, :team_name
    rename_column :outcomes, :team, :team_name
  end
end
