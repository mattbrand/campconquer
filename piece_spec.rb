require 'rspec'
require_relative 'piece'

describe Piece do
  it 'should have a point' do
    piece = Piece.new(name: 'Abby')
    expect(piece.position).to eq([0,0])
  end


  it 'should have a name' do
    piece = Piece.new(name: 'abby')
    expect(piece.name).to eq('abby')
  end

  it 'should have a destination' do
    piece = Piece.new(name: 'abby', destination: Point.new(1,1))
    expect(piece.destination).to eq([1,1])
  end

  it 'destination and position should default to 0,0' do
    piece = Piece.new(name: 'abby')
    expect(piece.position).to eq([0,0])
    expect(piece.destination).to eq([0,0])
  end

  it 'destination should default to initial position' do
    piece = Piece.new(name: 'abby', position: Point.new(1,2))
    expect(piece.destination).to eq([1,2])
  end

  it 'moves to a new position' do
    piece = Piece.new(name: 'abby')
    new_position = Point.new(1, 1)
    piece.move_to(new_position)

    expect(piece.position).to eq(new_position)
  end
end
