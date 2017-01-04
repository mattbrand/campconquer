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
    hash[:x] = hash.delete("X") if hash["X"]
    hash[:y] = hash.delete("Y") if hash["Y"]
    new(**hash.symbolize_keys)
  end

  def self.from_s(s)
    if s.blank?
      nil
    else
      Point.from_a(s.split(',').map(&:to_f))
    end
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

  def serializable_hash
    to_hash
  end

  def ==(other)
    other.is_a? Point and
        other.x == self.x and
        other.y == self.y
  end
end
