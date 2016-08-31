class AddStateToGame < ActiveRecord::Migration
  def change
    add_column :games, :state, :string, default: 'preparing'
    Game.connection.execute("UPDATE games SET state = 'in_progress' WHERE games.locked = 1")
    Game.connection.execute("UPDATE games SET state = 'completed' WHERE games.locked = 0 AND games.current = 0")
  end
end
