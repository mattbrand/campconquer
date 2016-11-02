class AddRolesToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :gamemaster, :boolean
    add_column :players, :admin, :boolean
  end
end
