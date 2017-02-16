class FixSeasonMemberships < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Season.all.each do |season|
          season.add_all_players
        end
      end
    end
  end
end
