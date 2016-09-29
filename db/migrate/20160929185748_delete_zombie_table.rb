# the player_outcomes table seems to exist somewhere and keeps reappearing in schema.rb;
# this should kill it for realsies
class DeleteZombieTable < ActiveRecord::Migration
  def change
    table_name = 'player_outcomes'
    drop_table table_name if ActiveRecord::Base.connection.table_exists? table_name
  end
end
