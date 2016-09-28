class AddBodyAndHairToGear < ActiveRecord::Migration
  def change
    add_column :gears, :hair, :string
    add_column :gears, :body_type, :string
  end
end
