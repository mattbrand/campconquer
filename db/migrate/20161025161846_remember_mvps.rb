class RememberMvps < ActiveRecord::Migration
  def change
    add_column :games, :mvps, :text
  end
end
