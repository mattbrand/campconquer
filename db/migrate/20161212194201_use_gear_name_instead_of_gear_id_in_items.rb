class UseGearNameInsteadOfGearIdInItems < ActiveRecord::Migration
  # so this migration will still work even if we delete the Gear table/object later
  class Gear < ActiveRecord::Base
  end

  def change
    change_table :items do |t|
      t.string :gear_name
    end

    reversible do |dir|
      dir.up do
        execute("UPDATE items SET gear_name = (SELECT name FROM gears g WHERE g.id=items.gear_id)")
      end
      dir.down do
        execute("UPDATE items SET gear_id = (SELECT id FROM gears g WHERE g.name=items.gear_name)")
      end
    end

    remove_column :items, :gear_id, :integer

  end

end
