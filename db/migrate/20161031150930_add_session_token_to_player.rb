class AddSessionTokenToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :session_token, :string
    add_index :players, :session_token
    add_column :players, :encrypted_password, :string
    add_column :players, :salt, :string
  end
end
