require 'rspec'
require_relative 'map'
require_relative 'flag'

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
      @abby = Piece.new(name: "abby")
      @map.add_piece(@abby)
    end

    it 'should have that piece' do
      expect(@map.pieces).to include(@abby)
    end

    it 'should know that piece\'s position' do
      expect(@map.position_of("abby")).to eq([0,0])
    end

    it 'can move the piece nowhere' do
      @map.move_pieces()
      expect(@map.position_of("abby")).to eq([0, 0])
    end

    it 'has a piece move until it hits the edge of the map in the x direction' do
      @abby.position = Point.new(10, 0)
      @abby.destination = Point.new(-1, 0)
      while(@abby.position.x > 0) do
        @map.move_pieces()
      end
      expect(@abby.position.x).to be <= 0
    end
  end

  describe 'when it has two pieces' do
    before do
      @map = Map.new
      @map.add_piece(Piece.new(name: "abby", destination: Point.new(10,10)))
      @map.add_piece(Piece.new(name: "daisy", destination: Point.new(10,0)))
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

  describe 'when it has a flag' do
    before do
      @map = Map.new
    end

    it 'has a flag that can have a position set' do
      @map.set_red_flag_position(Point.new(1, 2))
      expect(@map.flag_red.position).to eq([1,2])
    end

    it 'can move a piece until it hits the flag' do
      @abby = Piece.new(name: "abby", position: Point.new(10, 0), destination: Point.new(0, 0))
      @map.add_piece(@abby)
      @map.set_red_flag_position(Point.new(0, 0))

      while(!@map.is_piece_at_red_flag(@abby)) do
        @map.move_pieces()
      end
      expect(@map.is_piece_at_red_flag(@abby)).to be true
    end

    it 'changes status of flag to taken when piece hits the flag' do
      @abby = Piece.new(name: "abby", position: Point.new(10, 0), destination: Point.new(0, 0))
      @map.add_piece(@abby)
      @map.set_red_flag_position(Point.new(0, 0))

      while(!@map.is_piece_at_red_flag(@abby)) do
        @map.move_pieces()
      end
      expect(@map.flag_red.status).to eq "taken"
    end
  end
end
