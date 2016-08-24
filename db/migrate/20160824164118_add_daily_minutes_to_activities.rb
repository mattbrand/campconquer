class AddDailyMinutesToActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.boolean :moderate_minutes_claimed, null: false, default: false
      t.boolean :vigorous_minutes_claimed, null: false, default: false
    end
    rename_column :activities, :very_active_minutes, :vigorous_minutes
    rename_column :activities, :fairly_active_minutes, :moderate_minutes
    remove_column :activities, :lightly_active_minutes, :integer
  end
end
