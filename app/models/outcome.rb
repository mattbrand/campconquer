# == Schema Information
#
# Table name: outcomes
#
#  id                  :integer          not null, primary key
#  team                :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  player_id           :integer
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  game_id             :integer
#
# Indexes
#
#  index_outcomes_on_game_id    (game_id)
#  index_outcomes_on_player_id  (player_id)
#

class Outcome < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validates :team, inclusion: {in: Team::NAMES.values, message: Team::NAMES.validation_message}
  validates :player_id, presence: true # todo: should validate that it's a real player too

  before_save do
    # defend against nulls
    %w(takedowns throws pickups flag_carry_distance captures).each do |field|
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
      only: [:team,
             :player_id,
             :takedowns,
             :throws,
             :pickups,
             :captures,
             :flag_carry_distance,
      ],
    }
  end

end
