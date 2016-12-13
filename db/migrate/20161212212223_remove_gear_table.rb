class RemoveGearTable < ActiveRecord::Migration
  def change
    drop_table :gears
  end
end
