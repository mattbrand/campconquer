class IntegerFieldsShouldNotBeNullable < ActiveRecord::Migration
  def change
    {
      games: [:match_length],
      gears: [:health_bonus, :speed_bonus, :range_bonus, :coins, :gems, :level],
      outcomes: [:throws, :pickups, :captures],
      pieces: [:health],
      players: [:coins, :gems],
    }.each_pair do |table, fields|
      fields.each do |field|
        change_column_null table, field, false, 0
        change_column_default table, field, 0
      end
    end
  end
end
