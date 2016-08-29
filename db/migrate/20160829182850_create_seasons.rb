class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.timestamps
      t.string :name
      t.boolean :current, null: false, default: false
    end

    add_column :games, :season_id, :integer
    add_index :games, :season_id

    rename_table :team_outcomes, :player_outcomes
    change_table :player_outcomes do |t|
      t.integer :player_id
      t.integer :flag_carry_distance
      t.integer :captures
      t.integer :attack_mvp
      t.integer :defend_mvp
    end
    add_index :player_outcomes, :player_id

  end
end
