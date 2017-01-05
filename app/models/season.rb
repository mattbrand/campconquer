# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default("f"), not null
#

class Season < ActiveRecord::Base
  has_many :games, -> { includes(:player_outcomes) }

  has_many :pieces, through: :games
  has_many :players, -> { uniq }, through: :pieces

  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one season'

  def self.current
    current_season = where(current: true).first
    if current_season.nil?
      current_season = Season.create! current: true
    end
    current_season
  end

  def self.previous
    where(current: false).order(updated_at: :desc).first
  end

  def name
    super or id.to_s
  end

  # sum of all game outcomes per team
  def team_summaries
    Team::NAMES.values.map do |team_name|
      TeamSummary.new(team: team_name, games: self.games)
    end
  end

  # sum of all game outcomes per player
  def player_summaries
    players.map do |player|
      PlayerSummary.new(games: self.games, player: player)
    end
  end

  include ActiveModel::Serialization

  def as_json(options=nil)
    if options.nil?
      options = self.class.serialization_options
    end
    super(options)
  end

  def self.serialization_options
    {
      include: [
        :team_summaries,
        :player_summaries,
      ],
      methods: [:team_summaries, :player_summaries]
    }
  end

end
