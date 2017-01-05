class ChangeControlGroupToATeam < ActiveRecord::Migration
  def change
    Player.where(in_control_group: true).update_all(team: 'control')
    remove_column :players, :in_control_group
  end
end
