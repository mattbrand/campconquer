class AddCosmeticsToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :face, :string
    add_column :pieces, :hair, :string
    add_column :pieces, :skin_color, :string
    add_column :pieces, :hair_color, :string
  end
end
