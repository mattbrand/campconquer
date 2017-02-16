class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :season_id, null: false
      t.string :team_name, null: false
      t.integer :player_id, null: false
    end
  end
end
