class PlayerHasFitbit < ActiveRecord::Migration
  def change
    add_column :players, :fitbit_token_hash, :text
    add_column :players, :anti_forgery_token, :string
  end
end
