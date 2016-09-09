class RenameGoldToCoins < ActiveRecord::Migration
  def change
    rename_column :gears, :gold, :coins
  end
end
