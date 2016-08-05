# it's a model, and it's not persistent
# (except as an array inside Piece.path)
class Point
  attr_reader :x
  attr_reader :y

  def self.from_a(array)
    new(x: array[0], y: array[1])
  end

  def self.from_hash(hash)
    new(**hash.symbolize_keys)
  end

  def initialize(x:, y:)
    @x, @y = x, y
  end

  def to_a
    [@x, @y]
  end

  def to_hash
    {x: @x, y: @y}
  end

  def ==(other)
    other.is_a? Point and
      other.x == self.x and
      other.y == self.y
  end
end
