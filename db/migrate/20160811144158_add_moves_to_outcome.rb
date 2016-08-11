class AddMovesToOutcome < ActiveRecord::Migration
  def change
    add_column :outcomes, :moves, :text
  end
end
