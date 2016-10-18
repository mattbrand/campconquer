class RemoveMvpFromOutcomes < ActiveRecord::Migration
  def change
    remove_column :outcomes, :attack_mvp, :integer
    remove_column :outcomes, :defend_mvp, :integer
  end
end
