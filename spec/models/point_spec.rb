require 'rails_helper'

describe Point do
  it "can be initialized with x, y" do
    p = Point.new(x: 1, y: 2)
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

  it "equals a point with the same values" do
    expect(Point.new(x: 1, y: 2)).to eq(Point.new(x: 1, y: 2))
  end

  it "does not equal a point with different values" do
    expect(Point.new(x: 1, y: 2)).not_to eq(Point.new(x: 1, y: 9))
    expect(Point.new(x: 1, y: 2)).not_to eq(Point.new(x: 9, y: 2))
  end

  it "can turn into an array" do
    p = Point.new(x: 1, y: 2)
    expect(p.to_a).to eq([1, 2])
  end

  it "can be initialized from an array" do
    p = Point.from_a([1, 2])
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

  it "can turn into a hash" do
    p = Point.new(x: 1, y: 2)
    expect(p.to_hash).to eq({x: 1, y: 2})
  end

  it "can be initialized from a hash" do
    p = Point.from_hash({x: 1, y: 2})
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

  it "can be initialized from a hash with capitalized string keys" do
    p = Point.from_hash({"X" => 1, "Y" => 2})
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

  it "can be initialized from a string" do
    p = Point.from_s("1.1,2.2")
    expect(p.x).to eq(1.1)
    expect(p.y).to eq(2.2)
  end

  it "returns nil if string is empty" do
    p = Point.from_s("")
    expect(p).to be_nil
    p = Point.from_s(nil)
    expect(p).to be_nil
  end

  it "checks its parameters" do
    expect { Point.from_a([]) }.to raise_error(RuntimeError)
    expect { Point.from_a([1]) }.to raise_error(RuntimeError)
    expect { Point.from_a([1,2,3]) }.to raise_error(RuntimeError)
  end

end
