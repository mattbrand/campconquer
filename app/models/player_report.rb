class PlayerReport

  HEADERS = ['player_id',
             'player_name',
             'control_group',
             'games_played',
             'active_weekdays',
             'average_steps_per_day',
             'average_active_minutes_per_day']

  attr_reader :player

  def initialize(player:, timespan: nil, season: nil)
    @player, @timespan, @season = player, timespan, season
    raise "You must pass either a season or a timespan, not both" if @timespan && @season
    @timespan = @season.timespan if @season
  end

  def values
    HEADERS.map {|field| self.send(field)}
  end

  def player_id
    player.id
  end

  def player_name
    player.name
  end

  def control_group
    player.in_control_group?
  end

  def active_weekdays
    player.activities.order(date: :asc).
        where('active_minutes >= ?', [Player::GOAL_MINUTES]).
        where('date >= ?', @timespan.first).
        where('date < ?', @timespan.last).
        select {|activity| activity.date.weekday?}.
        count
  end

  def average_steps_per_day
    weekdays = @timespan.weekdays
    player.activities.where(date: weekdays).sum(:steps) / weekdays.size.to_f
  end

  def average_active_minutes_per_day
    weekdays = @timespan.weekdays
    player.activities.where(date: weekdays).sum(:active_minutes) / weekdays.size.to_f
  end

  def games_played
    if @season.nil? or control_group
      0
    else
      @season.reload # ActiveRecord is weird
      @season.games.select {|game| game.players.include? @player}.size
    end
  end

end
