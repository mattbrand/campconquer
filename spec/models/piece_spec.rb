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

  it "serializes a list of points into path" do


  end
end
