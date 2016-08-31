class GiveItemAnId < ActiveRecord::Migration
  def change
    add_column :items, :id, :primary_key, null: false, primary_key: true
  end
end
