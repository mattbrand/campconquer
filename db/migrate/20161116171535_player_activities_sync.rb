class PlayerActivitiesSync < ActiveRecord::Migration
  def change
    add_column :players, :activities_synced_at, :datetime
  end
end
