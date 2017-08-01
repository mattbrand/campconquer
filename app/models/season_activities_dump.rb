class SeasonActivitiesDump < Dump
  attr_reader :season

  def initialize season
    @season = season
  end

  def rows
    @rows ||=
        filled_activities.map do |activity|
          ActivityDump.new(season: season, activity: activity)
        end
  end

  def headers
    rows.first.headers
  end

  def filled_activities
    activity_map = {}
    season.timespan.each do |date|
      season.players.each do |player|
        activity_map[[date, player.id]] = Activity.new(player: player, date: date)
      end
    end

    # overwrite blank activities with real activities
    season_activities = season.activities.includes(:player) # should this be weekdays only?
    season_activities.each do |activity|
      activity_map[[activity.date, activity.player.id]] = activity
    end

    activities = activity_map.values.sort_by{|activity| [activity.date, activity.player_id]}
  end

end
