class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
      t.string :team
      t.string :job
      t.string :role
      t.text :path
      t.float :speed
      t.integer :hit_points
      t.float :range

      t.timestamps null: false
    end
  end
end
