class Piece
  attr_reader :name
  attr_reader :position
  attr_reader :destination

  def initialize(name:, position: Point.new(0,0), destination: position)
    @name = name
    @position = position
    @destination = destination
  end

  def move_to(new_position)
    @position = new_position
  end
end
