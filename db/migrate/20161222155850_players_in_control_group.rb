class PlayersInControlGroup < ActiveRecord::Migration
  def change
    add_column :players, :in_control_group, :boolean, null: false, default: false
  end
end
