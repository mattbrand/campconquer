class MergePlayerOutcomesIntoOutcomes < ActiveRecord::Migration
  def change
    change_table :games do |t|
      t.string   "winner"
      t.integer  "match_length"
    end
    drop_table :outcomes do
      # noop
    end
    rename_table :player_outcomes, :outcomes
    change_table :outcomes do |t|
      t.remove "outcome_id"
      t.references "game", foreign_key: true
    end
    add_index "outcomes", "game_id"
    add_index "pieces", "game_id"
    add_index "pieces", "player_id"
  end
end
