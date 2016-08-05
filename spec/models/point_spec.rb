require 'rails_helper'

describe Point do
  it "can be initialized with x, y" do
    p = Point.new(x:1, y:2)
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

  it "can turn into an array" do
    p = Point.new(x:1, y:2)
    expect(p.to_a).to eq([1,2])
  end

  it "can be initialized from an array" do
    p = Point.from_a([1,2])
    expect(p.x).to eq(1)
    expect(p.y).to eq(2)
  end

end
