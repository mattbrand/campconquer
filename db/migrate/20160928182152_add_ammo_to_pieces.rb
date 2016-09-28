class AddAmmoToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :ammo, :text
  end
end
