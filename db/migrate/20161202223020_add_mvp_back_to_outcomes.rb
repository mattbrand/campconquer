class AddMvpBackToOutcomes < ActiveRecord::Migration
  def change
    add_column :outcomes, :attack_mvp, :boolean, null: false, default: false
    add_column :outcomes, :defend_mvp, :boolean, null: false, default: false
  end
end
