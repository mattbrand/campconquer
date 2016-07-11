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
  it "validates team"
  it "validates job"
  it "validates role"
  it "serializes a list of points into path"
end
