class SeasonPlayerDump < Dump
  def headers
    [
      'season_id',

      'player_id',
      'player_name',

      'control_group',

      'team_name',
      'role',
      'speed',
      'health',
      'range',

      'last_synced',
      'last_active',

      'games_played',
    ]
  end

  attr_reader :season, :player

  def initialize(season:, player:)
    @season, @player = season, player
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
    player.name # todo: also link to player_path(player)
  end

  def control_group
    player.in_control_group?
  end

  def team_name
    player.team_name
  end

  def role
    player.role
  end

  def speed
    player.speed
  end

  def health
    player.health
  end

  def range
    player.range
  end

  def games_played
    games = season.games
    games.preload(:pieces)
    games.select {|game| game.pieces.map(&:player_id).include? player.id}.size
  end

  def last_synced
    player.activities_synced_at # TODO: datetime formatting .try(:strftime, "%A, %B %-d, %Y, %l:%M %p %Z")
  end

  def last_active
    player.most_recent_activity.try(:date)
  end

  def actions
    # TODO: generate or accept form with action buttons
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
