# == Schema Information
#
# Table name: outcomes
#
#  id           :integer          not null, primary key
#  winner       :string
#  match_length :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  game_id      :integer
#
# Indexes
#
#  index_outcomes_on_game_id  (game_id)
#

class Outcome < ActiveRecord::Base
  belongs_to :game
  has_many :player_outcomes, dependent: :destroy
  accepts_nested_attributes_for :player_outcomes

  validates :winner, inclusion: {
    in: Team::NAMES.values + ["none"],
    message: Team::NAMES.validation_message + ' or "none"',
  }

  # include ActiveModel::Serialization
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
      only: [:winner,
             :match_length,
             :created_at,
             :updated_at,
      ],
      methods: [:team_outcomes],
      include: [{:player_outcomes => PlayerOutcome.serialization_options},
      :team_outcomes
      ]
    }
  end

  def team_outcomes
    Team::NAMES.values.map do |team_name|
      TeamOutcome.new(team: team_name, games: [game])
    end
  end

end
