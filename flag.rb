class Flag
  attr_reader :team_color
  attr_writer :team_color
  attr_reader :position
  attr_writer :position
  attr_reader :status
  attr_writer :status

  def initialize(team_color, position: Point.new(0,0))
    @team_color = team_color
    @position = position
    @status = "free"
  end
end
