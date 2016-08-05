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

  context "gear" do
    let!(:piece) { Piece.create!(team: 'blue') }
    let!(:tee_shirt) { Gear.create!(name: 'T-Shirt', gear_type: 'shirt') }
    let!(:galoshes) { Gear.create!(name: 'Galoshes', gear_type: 'shoes') }

    before do
      piece.items.create!(gear_id: tee_shirt.id)
      piece.items.create!(gear_id: galoshes.id, equipped: true)
      piece.reload # :-( -- otherwise we get duplicates for some dumb reason
    end

    it "has items" do
      expect(piece.items.size).to eq(2)
      expect(piece.items.map(&:gear)).to include(tee_shirt)
      expect(piece.items.map(&:gear)).to include(galoshes)
    end

    it "has equipped items" do
      expect(piece.items_equipped.size).to eq(1)
      expect(piece.items.map(&:gear)).to include(galoshes)
    end

    it "jsons all items as gear" do
      expect(piece.as_json['gear_owned']).to eq([tee_shirt.name, galoshes.name])
    end

    it "jsons equipped items as gear_equipped" do
      expect(piece.as_json['gear_equipped']).to eq([galoshes.name])
    end
  end
end
