require 'rspec'
require_relative 'map'

describe Map do

  DIAGONAL_DISTANCE = Math.sqrt(0.5)

  describe 'when empty' do
    before do
      @map = Map.new
    end

    it 'should have no pieces' do
      expect(@map.pieces).to be_empty
    end
  end

  describe 'when it has one piece' do
    before do
      @map = Map.new
      @map.add_piece({name: "abby"})
    end

    it 'should have that piece' do
      expect(@map.pieces).to include({name: "abby", position: Point.new(0,0), destination: Point.new(0, 0)})
    end

    it 'should know that piece\'s position' do
      expect(@map.position_of("abby")).to eq([0,0])
    end

    it 'can move the piece nowhere' do
      @map.move_pieces()
      expect(@map.position_of("abby")).to eq([0, 0])
    end
  end

  describe 'when it has two pieces' do
    before do
      @map = Map.new
      @map.add_piece({name: "abby", destination: Point.new(10,10)})
      @map.add_piece({name: "daisy", destination: Point.new(10,0)})
    end

    it 'should know both piece\'s positions' do
      expect(@map.position_of("abby")).to eq([0,0])
      expect(@map.position_of("daisy")).to eq([0,0])
    end

    it 'can move the pieces' do
      @map.move_pieces()
      expect(@map.position_of("abby").x).to be_within(0.1).of(DIAGONAL_DISTANCE)
      expect(@map.position_of("abby").y).to be_within(0.1).of(DIAGONAL_DISTANCE)

      expect(@map.position_of("daisy")).to eq([1,0])
    end

  end
end
