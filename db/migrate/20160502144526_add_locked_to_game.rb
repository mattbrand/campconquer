class AddLockedToGame < ActiveRecord::Migration
  def change
    add_column :games, :locked, :boolean
  end
end
