
# it's a model, and it's not persistent
# (except as an array inside Piece.path)
class Point
  attr_reader :x
  attr_reader :y

  def initialize(x: , y:)
    @x = x
    @y = y
  end
end
