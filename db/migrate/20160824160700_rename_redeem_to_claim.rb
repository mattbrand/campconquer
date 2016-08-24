class RenameRedeemToClaim < ActiveRecord::Migration
  def change
    rename_column :activities, :steps_redeemed, :steps_claimed
  end
end
