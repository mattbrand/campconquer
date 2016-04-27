require 'rspec'
require_relative 'point'

describe Point do

  it 'should have floating-point values for coordinates' do
    point = Point.new(0.5, 0.5)
    expect(point.x).to eq(0.5)
    expect(point.y).to eq(0.5)
  end

  it 'has an array version of itself' do
    point = Point.new(0.5, 0.5)
    expect(point.to_a).to eq([0.5, 0.5])
  end

  it 'is equal to the array version of itself' do
    point = Point.new(0.5, 0.5)
    expect(point == [0.5, 0.5]).to be_truthy
  end

  it 'knows the x,y offset to another point' do
    start = Point.new(1,1)
    finish = Point.new(2,3)
    offset = start.offset_to(finish)
    expect(offset.x).to eq(1)
    expect(offset.y).to eq(2)
  end
end
