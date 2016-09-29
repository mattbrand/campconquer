class AddEmbodiedToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :embodied, :boolean, default: false, null: false
  end
end
