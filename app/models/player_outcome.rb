# == Schema Information
#
# Table name: player_outcomes
#
#  id                  :integer          not null, primary key
#  team                :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  outcome_id          :integer
#  player_id           :integer
#  flag_carry_distance :integer
#  captures            :integer
#  attack_mvp          :integer
#  defend_mvp          :integer
#
# Indexes
#
#  index_player_outcomes_on_outcome_id  (outcome_id)
#  index_player_outcomes_on_player_id   (player_id)
#

class PlayerOutcome < ActiveRecord::Base
  belongs_to :outcome
  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}

  include ActiveModel::Serialization
  def as_json(options=nil)
    if options.nil?
      options = self.class.serialization_options
    end
    super(options)
  end

  # Rails doesn't recursively call as_json or serializable_hash
  # so we have to call these options explicitly from the parent's as_json
  def self.serialization_options
    {
      only: [:team,
             :takedowns,
             :throws,
             :pickups,
             :captures,
             :attack_mvp,
             :defend_mvp],
    }
  end
end
