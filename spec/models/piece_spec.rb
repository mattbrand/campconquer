# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  team       :string
#  role       :string
#  path       :text
#  speed      :float
#  health     :integer
#  range      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  player_id  :integer
#  body_type  :string
#

require 'rails_helper'

RSpec.describe Piece, type: :model do

  it "validates team" do
    expect(Piece.new(team: 'blue')).to be_valid
    expect(Piece.new(team: 'mauve')).not_to be_valid
  end

  it "validates body" do
    expect(Piece.new(team: 'blue', body_type: 'male')).to be_valid
    expect(Piece.new(team: 'blue', body_type: 'alien')).not_to be_valid
  end

  it "validates role" do
    expect(Piece.new(team: 'blue', role: 'offense')).to be_valid
    expect(Piece.new(team: 'blue', role: 'management')).not_to be_valid
  end

  context "path" do
    let(:point1_2) { Point.new(x: 1, y: 2) }
    let(:point3_4) { Point.new(x: 3, y: 4) }

    it "serializes a list of points into path" do
      piece = Piece.new(team: 'blue', path: [point1_2, point3_4])
      piece.save!
      piece.reload
      expect(piece.path).to eq([point1_2, point3_4])
    end

    it "serializes a list of tuples into path" do
      piece = Piece.new(team: 'blue', path: [[1, 2], [3, 4]])
      piece.save!
      piece.reload
      expect(piece.path).to eq([point1_2, point3_4])
    end

    it "serializes a list of hashes into path" do
      piece = Piece.new(team: 'blue', path: [{x:1, y:2}, {x:3, y:4}])
      piece.save!
      piece.reload
      expect(piece.path).to eq([point1_2, point3_4])
    end

    it "gets as_jsoned as a list of hashes" do
      piece = Piece.new(team: 'blue', path: [[1, 2], [3, 4]])
      expect(piece.as_json['path']).to eq([{x:1, y:2}, {x:3, y:4}])
    end
  end
end
