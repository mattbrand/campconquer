class MergeVigorousAndModerateMinutes < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.rename :vigorous_minutes, :active_minutes
      t.rename :vigorous_minutes_claimed, :active_minutes_claimed
      t.remove :moderate_minutes, :moderate_minutes_claimed
    end

  end
end
