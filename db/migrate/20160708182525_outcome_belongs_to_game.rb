class OutcomeBelongsToGame < ActiveRecord::Migration
  def change
    add_column :outcomes, :game_id, :integer
    add_index :outcomes, :game_id

  end
end
