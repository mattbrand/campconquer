# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  team       :string
#  job        :string
#  role       :string
#  path       :text
#  speed      :float
#  hit_points :integer
#  range      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  player_id  :integer
#

require 'rails_helper'

RSpec.describe Piece, type: :model do
  it "validates team" do
    expect(Piece.new(team: 'blue')).to be_valid
    expect(Piece.new(team: 'mauve')).not_to be_valid
  end
  it "validates job" do
      expect(Piece.new(team: 'blue', job: 'bruiser')).to be_valid
      expect(Piece.new(team: 'blue', job: 'coder')).not_to be_valid
    end
  it "validates role" do
    expect(Piece.new(team: 'blue', role: 'offense')).to be_valid
    expect(Piece.new(team: 'blue', role: 'management')).not_to be_valid
  end
  it "serializes a list of points into path"
end
