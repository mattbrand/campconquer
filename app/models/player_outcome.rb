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
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  attack_mvp          :integer          not null
#  defend_mvp          :integer          not null
#
# Indexes
#
#  index_player_outcomes_on_outcome_id  (outcome_id)
#  index_player_outcomes_on_player_id   (player_id)
#

class PlayerOutcome < ActiveRecord::Base
  belongs_to :outcome
  validates :team, inclusion: {in: Team::NAMES.values, message: Team::NAMES.validation_message}
  validates :player_id, presence: true # todo: should validate that it's a real player too

  before_save do
    # defend against nulls
    %w(takedowns throws pickups flag_carry_distance captures attack_mvp defend_mvp).each do |field|
      self[field] ||= 0
    end

  end

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
             :player_id,
             :takedowns,
             :throws,
             :pickups,
             :captures,
             :flag_carry_distance,
             :attack_mvp,
             :defend_mvp,
      ],
    }
  end
end
