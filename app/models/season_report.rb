class SeasonReport
  def initialize season
    @season = season
  end

  def players
    @season.pieces.order(team_name: :asc).all.map do |piece|
      piece.player
    end
  end

  def html(out="")
    out << "    <table class='info-table'>"
    out << "    <tr>"
    headers = PlayerReport::HEADERS
    headers.each do |name|
      out << "        <th>#{ name }</th>"
    end
    out << "  </tr>"
    players.each do |player|
      PlayerReport.new(season: @season, player: player).html(out)
    end
    out << "    </table>"
    out
  end

  def csv
    CSV.generate do |out|
      out << PlayerReport::HEADERS
      players.each do |player|
        PlayerReport.new(season: @season, player: player).csv(out)
      end
    end
  end
end
