class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :player_id
      t.string :token

      t.index :player_id
      t.index :token

      t.timestamps null: false
    end
  end
end
