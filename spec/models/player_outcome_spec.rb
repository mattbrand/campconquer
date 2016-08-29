# == Schema Information
#
# Table name: player_outcomes
#
#  id         :integer          not null, primary key
#  player       :string
#  takedowns  :integer
#  throws     :integer
#  pickups    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  outcome_id :integer
#
# Indexes
#
#  index_player_outcomes_on_outcome_id  (outcome_id)
#

require 'rails_helper'

RSpec.describe PlayerOutcome, type: :model do
  it "requires player name" do
    player_outcome = PlayerOutcome.new(team: nil)
    expect(player_outcome).not_to be_valid
  end

  it "validates player name" do
    player_outcome = PlayerOutcome.new(team: 'blue')
    expect(player_outcome).to be_valid
  end
end
