class Map
  WIDTH = 50
  HEIGHT = 50

  attr_reader :pieces
  attr_reader :flag_red
  attr_reader :flag_blue

  def initialize
    @pieces = []
    @flag_red = Flag.new(team_color: "red", position: Point.new(0, 0))
    @flag_blue = Flag.new(team_color: "blue", position: Point.new(WIDTH, HEIGHT))
  end

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

  def set_red_flag_position(position)
    @flag_red.position = position
  end

  def is_piece_at_red_flag(piece)
    x_diff = (piece.position.x - @flag_red.position.x).abs
    y_diff = (piece.position.y - @flag_red.position.y).abs
    if(x_diff < 0.5 && y_diff < 0.5)
      @flag_red.status = "taken"
      true
    else
      false
    end
  end
end
