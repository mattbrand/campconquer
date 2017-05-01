class PlayerReport

  attr_reader :player

  def initialize(player:, timespan:)
    @player, @timespan = player, timespan
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

end
