# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default("f"), not null
#  start_at   :date
#

class Season < ActiveRecord::Base
  has_many :games, -> { includes(:player_outcomes) }

  has_many :pieces, through: :games

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

  after_create do
    self.start_at = Chronic.parse("next Sunday").to_date if self.start_at.nil?
  end

  def start_at
    super.try(:to_date)
  end

  # was has_many :players, -> { uniq }, through: :pieces
  # but we need a better season/player/game hierarchy and workflow
  def players
    Player.all
  end

  def begun?
    self.games.count > 0
  end

  def name
    super or id.to_s
  end

  # sum of all game outcomes per team
  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team: team_name, games: self.games)
    end
  end

  # sum of all game outcomes per player
  def player_summaries
    players.map do |player|
      PlayerSummary.new(games: self.games, player: player)
    end
  end

  def week n
    if n == 0
      week_games = games.where(state: 'completed').where(["played_at < ?", self.start_at])
      week_start = nil
    else
      start = self.start_at + (n-1).weeks
      finish = self.start_at + (n).weeks

      week_games = games.where(state: 'completed').where(["played_at >= ? AND played_at < ?", start, finish])
      week_start = start
    end

    Week.new(number: n, start_at: week_start, games: week_games)
  end

  def weeks
    latest_game = games.where(state: 'completed').sort_by(&:played_at).last
    return [] unless latest_game
    list = all_weeks(latest_game.played_at)

    # sanity check
    week_game_count = list.inject(0) { |sum, week| sum + week.size }

    raise "Assertion failed: #{week_game_count} != #{games.select{|g| g.completed?}.count}" if week_game_count != games.count

    list
  end

  private
  def all_weeks(latest_game_played_at)
    list = []
    number_of_weeks(latest_game_played_at).times do |i|
      list << week(i)
    end
    list
  end

  def number_of_weeks(latest_game_played_at)
    if latest_game_played_at < self.start_at.to_date
      1
    else
      number_of_days = (latest_game_played_at.to_date - self.start_at.to_date).to_i
      number_of_days / 7 + 2 # +1 for preseason, +1 for the remainder
    end
  end

  public

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
