class AddMoreGearFields < ActiveRecord::Migration
  def change
    add_column :gears, :gear_type, :string
    add_column :gears, :asset_name, :string
    add_column :gears, :icon_name, :string
    add_column :gears, :gold, :integer, null: false, default: 0
    add_column :gears, :gems, :integer, null: false, default: 0
    add_column :gears, :level, :integer, null: false, default: 0
  end
end
