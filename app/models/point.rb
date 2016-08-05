# it's a model, and it's not persistent
# (except as an array inside Piece.path)
class Point
  attr_reader :x
  attr_reader :y

  def self.from_a(array)
    new(x: array[0], y: array[1])
  end

  def initialize(x:, y:)
    @x, @y = x, y
  end

  def to_a
    [@x, @y]
  end
end
