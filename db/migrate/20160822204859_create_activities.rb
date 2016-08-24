class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :player_id
      t.date  :date
      t.timestamps

      t.integer :steps, null: false, default: 0
      t.integer :steps_redeemed, null: false, default: 0
      t.integer :very_active_minutes, null: false, default: 0
      t.integer :fairly_active_minutes, null: false, default: 0
      t.integer :lightly_active_minutes, null: false, default: 0

    end
    add_index :activities, :player_id
    add_index :activities, :date
  end
end
