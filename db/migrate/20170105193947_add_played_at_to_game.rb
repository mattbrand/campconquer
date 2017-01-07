class AddPlayedAtToGame < ActiveRecord::Migration
  def up
    add_column :games, :played_at, :datetime
    Game.where(played_at: nil, state: 'completed').update_all(played_at: Time.current)
  end
  def down
    remove_column :games, :played_at, :datetime
  end
end
