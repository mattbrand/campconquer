class PlayerReport

  HEADERS = ['player_id',
             'player_name',
             'control_group',
             'games_played',
             'activity_goal_reached',
             'mean_steps_per_day',
             'mean_active_minutes_per_day']

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

  def activity_goal_reached
    weekday_activities_where_goal_reached.size
  end

  def mean_steps_per_day
    mean_per_day(weekday_activities.sum(:steps))
  end

  def mean_active_minutes_per_day
    mean_per_day(weekday_activities.sum(:active_minutes))
  end

  def games_played
    if @season.nil? or control_group
      0
    else
      @season.reload # ActiveRecord is weird
      @season.games.select {|game| game.players.include? @player}.size
    end
  end

  private

  def weekdays
    @timespan.weekdays
  end

  def weekday_activities
    player.activities.order(date: :asc).where(date: weekdays)
  end

  def weekday_activities_where_goal_reached
    weekday_activities.where('active_minutes >= ?', [Player::GOAL_MINUTES])
  end

  def mean_per_day total
    (total / weekdays.size.to_f).round(2)
  end

end
