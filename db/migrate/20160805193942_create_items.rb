class CreateItems < ActiveRecord::Migration
  def change
    create_join_table :pieces, :gears, table_name: 'items' do |t|
      t.index [:piece_id, :gear_id]
      t.boolean :equipped, default: false, null: false
    end
  end
end
