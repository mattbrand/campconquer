# == Schema Information
#
# Table name: player_outcomes
#
#  id                  :integer          not null, primary key
#  team                :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  outcome_id          :integer
#  player_id           :integer
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  attack_mvp          :integer          not null
#  defend_mvp          :integer          not null
#
# Indexes
#
#  index_player_outcomes_on_outcome_id  (outcome_id)
#  index_player_outcomes_on_player_id   (player_id)
#

require 'rails_helper'

describe PlayerOutcome do
  it "requires player name" do
    player_outcome = PlayerOutcome.new(team: nil)
    expect(player_outcome).not_to be_valid
  end

  it "validates player name" do
    NOT_A_REAL_PLAYER_ID = 0 # todo: make a real player using factories
    player_outcome = PlayerOutcome.new(team: 'blue', player_id: NOT_A_REAL_PLAYER_ID)
    expect(player_outcome).to be_valid
  end


end
