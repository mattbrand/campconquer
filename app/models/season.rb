# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default(FALSE), not null
#  start_at   :date
#

class Season < ActiveRecord::Base
  has_many :games, -> { includes(:player_outcomes) }

  has_many :pieces, through: :games

  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one season'

  has_many :memberships

  has_many :players, through: :memberships

  def team_members(team_name)
    memberships.where(season_id: self.id, team_name: team_name).all.map(&:player)
  end

  def self.current
    current_season = where(current: true).first
    if current_season.nil?
      current_season = Season.create! current: true
      current_season.add_all_players # ?
    end
    current_season
  end

  def self.previous
    where(current: false).order(updated_at: :desc).first
  end

  before_create do
    self.start_at = Chronic.parse("next Sunday").to_date if self.start_at.nil?
  end

  after_create do
    add_all_players
  end

  def start_at
    super.try(:to_date)
  end

  def add_all_players
    Player.all.each do |player|
      add_player(player) unless players.include?(player)
    end
  end

  def add_player(player)
    memberships.create! player_id: player.id, team_name: player.team_name
  end

  def start!
    Season.where(current: true).update_all(current: false)
    update!(current: true)
    memberships.includes(:player).includes(:piece).each do |membership|
      membership.set_player_team!
    end
  end

  def begun?
    self.games.count > 0  # or, today >= start_at?
  end

  def name
    super or "Season #{id}"
  end

  # sum of all game outcomes per team_name
  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team_name: team_name, games: self.games)
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
      week_start = Date.current - 1.year
      week_finish = self.start_at
    else
      week_start = self.start_at + (n-1).weeks
      week_finish = self.start_at + (n).weeks
    end
    week_games = games.where(state: 'completed').where(["played_at >= ? AND played_at < ?", week_start, week_finish])

    Week.new(number: n, start_at: week_start, finish_at: week_finish, games: week_games)
  end

  def weeks
    latest_game = games.where(state: 'completed').sort_by(&:played_at).last
    return [] unless latest_game
    list = all_weeks(latest_game.played_at)

    # sanity check
    week_game_count = list.inject(0) { |sum, week| sum + week.size }
    completed_games = games.select { |g| g.completed? }
    raise "Assertion failed: #{week_game_count} != #{completed_games.size}" if week_game_count != completed_games.size

    list
  end

  def switch_team player, new_team
    membership = memberships.where(player_id: player.id).first
    membership.update!(team_name: new_team)
    if current?
      membership.set_player_team!
      player.piece.update(path: nil)
    end
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
