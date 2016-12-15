class RemoveLockedColumn < ActiveRecord::Migration
  def change
    remove_column :games, :locked, :boolean
  end
end
