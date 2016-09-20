class AddStateToGame < ActiveRecord::Migration
  def change
    add_column :games, :state, :string, default: 'preparing'
    Game.connection.execute("UPDATE games SET state = 'in_progress' WHERE games.locked IS TRUE")
    Game.connection.execute("UPDATE games SET state = 'completed' WHERE games.locked IS FALSE AND games.current IS FALSE")
  end
end
