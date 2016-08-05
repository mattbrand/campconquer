# it's a model, and it's not persistent
# (except as an array inside Piece.path)
class Point
  attr_reader :x
  attr_reader :y

  def self.from_a(tuple)
    raise "Point.from_a expected a 2-tuple but received #{tuple.inspect}" unless tuple.size == 2
    new(x: tuple[0], y: tuple[1])
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
