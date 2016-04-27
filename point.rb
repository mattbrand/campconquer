class Point
  def initialize(x,y)
    @x = x
    @y = y
  end

  attr_reader :x
  attr_reader :y

  def to_a
    [@x, @y]
  end

  def ==(other)
    other.to_a == self.to_a
  end

  def offset_to(destination)
    x_to_destination = destination.x - self.x
    y_to_destination = destination.y - self.y
    Point.new(x_to_destination, y_to_destination)
  end
end
