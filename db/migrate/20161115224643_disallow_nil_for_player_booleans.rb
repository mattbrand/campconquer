class DisallowNilForPlayerBooleans < ActiveRecord::Migration
  def change
    change_column_default :players, :admin, false
    change_column_default :players, :gamemaster, false
    change_column_null :players, :admin, false, false
    change_column_null :players, :gamemaster, false, false
  end
end
