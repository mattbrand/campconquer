class AddStartTimeToGame < ActiveRecord::Migration
  def change
    add_column :games, :scheduled_start, :datetime
  end
end
