# == Schema Information
#
# Table name: outcomes
#
#  id                  :integer          not null, primary key
#  team_name           :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  player_id           :integer
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  game_id             :integer
#  attack_mvp          :boolean          default(FALSE), not null
#  defend_mvp          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_outcomes_on_game_id    (game_id)
#  index_outcomes_on_player_id  (player_id)
#

class Outcome < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validates :team_name, inclusion: {in: Team::GAME_TEAMS.values, message: Team::GAME_TEAMS.validation_message}
  validates :player_id, presence: true # todo: should validate that it's a real player too

  class PlayerExists < ActiveModel::Validator
    def validate(record)
      if record.player.nil?
        record.errors[:base] << "Player #{record.player_id} not found"
      end
    end
  end
  validates_with PlayerExists, fields: [:player_id]

  before_save do
    # defend against nulls
    self.class.numeric_fields.each do |field|
      self[field] ||= 0
    end
  end

  def as_json(options=nil)
    options = self.class.serialization_options if options.nil?
    super(options)
  end

  # Rails doesn't recursively call as_json or serializable_hash
  # so we have to call these options explicitly from the parent's as_json
  def self.serialization_options
    {
        only: [:team_name, :player_id] + numeric_fields + [:attack_mvp, :defend_mvp],
    }
  end

  def self.numeric_fields
    [
        :takedowns,
        :throws,
        :pickups,
        :captures,
        :flag_carry_distance,
    ]
  end

end
