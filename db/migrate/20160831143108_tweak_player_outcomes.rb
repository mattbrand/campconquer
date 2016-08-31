class TweakPlayerOutcomes < ActiveRecord::Migration
  def change

    [:flag_carry_distance, :captures, :attack_mvp, :defend_mvp].each do |field|

      PlayerOutcome.connection.execute("UPDATE player_outcomes SET #{field} = 0 WHERE #{field} IS NULL")

      change_column_null :player_outcomes, field, false
      change_column_default :player_outcomes, field, from: nil, to: 0
    end

    add_foreign_key :player_outcomes, :outcome_id
    add_foreign_key :player_outcomes, :player_id

  end
end
