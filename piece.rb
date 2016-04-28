class Piece
  attr_reader :name
  attr_reader :team_color
  attr_writer :team_color
  attr_reader :
  attr_reader :position
  attr_writer :position
  attr_reader :destination
  attr_writer :destination

  def initialize(name:, team_color: "", position: Point.new(0,0), destination: position)
    @name = name
    @team_color = team_color
    @position = position
    @destination = destination
  end

  def move_to(new_position)
    @position = new_position
  end
end
