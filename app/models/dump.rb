# day x player
# - did they wear the fitbit?
# - activity data
# - # of games played


# week x player
# - # of games played
# season x player
# - # of games played

class Dump

  def headers
    [
        'season_id',

        'player_id',
        'player_name',

        'control_group',

        'date',
        'weekday',
        'active',
        'steps',
        'active_minutes',
        'active_goal_met',

        'games_played',
    ]
  end

  attr_reader :season, :activity

  def initialize(season:, activity:)
    @season, @activity = season, activity
  end

  def player
    activity.player
  end

  def values
    headers.map {|field| self.send(field)}
  end

  def season_id
    season.id
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

  def date
    activity.date
  end

  def weekday
    date.weekday?
  end

  def active
    activity.active?
  end

  def steps
    activity.steps
  end

  def active_minutes
    activity.active_minutes
  end

  def active_goal_met
    activity.active_goal_met?
  end

  def games_played
    games = season.games
    games.preload(:pieces)
    games.select {|game| game.date == date and game.pieces.map(&:player_id).include? player.id}.size
  end

  ##

  def html(out="")
    out << "      <tr>"
    values.each do |value|
      out << "            <td>#{ value }</td>"
    end
    out << "      </tr>"
    out
  end

  def csv(out)
    out << values
  end


  def html_headers(out="")
    out << "      <tr>"
    headers.each do |header|
      out << "            <th>#{ header }</th>"
    end
    out << "      </tr>"
    out
  end

  def csv_headers(out)
    out << headers
  end

end
