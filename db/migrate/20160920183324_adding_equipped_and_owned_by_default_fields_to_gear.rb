class AddingEquippedAndOwnedByDefaultFieldsToGear < ActiveRecord::Migration
  def change
    rename_column :gears, "default", "equipped_by_default"
    add_column :gears, "owned_by_default", :boolean, null: false, default: false
  end
end
