class ChangeStatsToInts < ActiveRecord::Migration
  def change
    change_column :pieces, :health, :integer, default: 0, null: false
    change_column :pieces, :speed, :integer, default: 0, null: false
    change_column :pieces, :range, :integer, default: 0, null: false
  end
end
