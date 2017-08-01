class SeasonPlayersDump < Dump
  attr_reader :season

  def initialize season
    @season = season
  end

  def rows
    @rows ||=
      players.map do |player|
        SeasonPlayerDump.new(season: season, player: player)
      end
  end

  def headers
    rows.first.headers
  end

  protected

  def players
    season.players.order(:team_name)
  end


end
