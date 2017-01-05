class AddStartAtDateToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :start_at, :date
    reversible do |dir|
      dir.up do
        # this is kind of a hack but we really need a season to have a start date now
        Season.where(start_at: nil).update_all(start_at: Chronic.parse("last Sunday"))
      end
    end
  end
end
