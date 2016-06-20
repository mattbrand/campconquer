class CreateOutcomes < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      t.string :winner
      t.integer :team_stats_id
      t.integer :match_length

      t.timestamps null: false
    end
  end
end
