class ChangeControlGroupToATeam < ActiveRecord::Migration
  def up
    Player.where(in_control_group: true).update_all(team: 'control')
    remove_column :players, :in_control_group, :boolean
  end
  def down
    add_column :players, :in_control_group, :boolean
    Player.where(team: 'control').update_all(in_control_group: true)
  end
end
