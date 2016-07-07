# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team name" do
    player = Player.new(name: "Joe", team: :blue)
    expect(player).to be_valid
  end
end
