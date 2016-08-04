class GearsOfWar < ActiveRecord::Migration
  def change
    create_table :gears do |t|
      t.string :name
      t.string :display_name
      t.string :description
      t.integer :health_bonus
      t.integer :speed_bonus
      t.integer :range_bonus
    end
  end
end
