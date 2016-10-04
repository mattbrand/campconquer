class AddColorDecalToGear < ActiveRecord::Migration
  def change
    add_column :gears, "color_decal", :boolean, null: false, default: false
  end
end
