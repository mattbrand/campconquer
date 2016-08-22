class AddExerciseFieldsToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.integer :coins, null: false, default: 0
      t.integer :gems, null: false, default: 0
    end
  end
end
