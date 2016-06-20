class CreateTeamOutcomes < ActiveRecord::Migration
  def change
    create_table :team_outcomes do |t|
      t.string :team
      t.integer :deaths
      t.integer :takedowns
      t.integer :throws
      t.integer :captures

      t.timestamps null: false
    end
  end
end
