
class Map
  def initialize
    @pieces = []
  end

  attr_reader :pieces

  def add_piece(piece)
    pieces.push(piece)
  end

  def move_pieces()
    pieces.each do |piece|

      position = piece.position
      destination = piece.destination
      velocity = 1.to_f

      if position == destination
        break
      end

      offset = position.offset_to(destination)
      total_distance = Math.sqrt(offset.x**2 + offset.y**2 )
      delta_x = offset.x * velocity / total_distance
      delta_y = offset.y * velocity / total_distance

      new_position = Point.new(position.x + delta_x, position.y + delta_y)
      piece.move_to(new_position)
    end
  end

  def piece_named(name)
    pieces.detect do |piece|
      piece.name == name
    end
  end

  def position_of(name)
    piece = piece_named(name)
    piece.position
  end
end

