class SeasonDump
  attr_reader :season

  def initialize season
    @season = season
  end

  def dumps
    @dumps ||=
        filled_activities.map do |activity|
          Dump.new(season: season, activity: activity)
        end
  end

  def headers
    dumps.first.headers
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


  def html(out="")
    out << "    <table class='info-table'>"
    out << "    <tr>"
    headers.each do |name|
      out << "        <th>#{ name }</th>"
    end
    out << "  </tr>"

    dumps.each do |dump|
      dump.html(out)
    end

    out << "    </table>"
    out
  end

  def csv
    CSV.generate do |out|
      out << headers
      dumps.each do |dump|
        dump.csv(out)
      end
    end
  end
end
