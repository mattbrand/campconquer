class AddCurrentFlagToGames < ActiveRecord::Migration
  def change
    add_column :games, :current, :boolean, default: false
    add_index :games, :current
  end
end
