class MoveMovesToGame < ActiveRecord::Migration
  def change
    remove_column :outcomes, :moves, :text
    add_column :games, :moves, :text
  end
end
