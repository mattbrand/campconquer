class AddDefaultFieldToGear < ActiveRecord::Migration
  def change
    add_column :gears, :default, :boolean, null: false, default: false # "is this piece of gear owned by default?"
  end
end
