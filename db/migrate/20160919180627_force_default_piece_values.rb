class ForceDefaultPieceValues < ActiveRecord::Migration
  def change
    table = :pieces
    [:speed, :health, :range].each do |field|
      change_column_null table, field, false, 0
      change_column_default table, field, 0
    end
  end
end
