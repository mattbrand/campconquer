# == Schema Information
#
# Table name: outcomes
#
#  id                  :integer          not null, primary key
#  team                :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  player_id           :integer
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  attack_mvp          :integer          not null
#  defend_mvp          :integer          not null
#  game_id             :integer
#
# Indexes
#
#  index_outcomes_on_game_id    (game_id)
#  index_outcomes_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Outcome, type: :model do

  let!(:player) { Player.create! name: 'alice', team: 'red' }

  it "requires a team" do
    outcome = Outcome.new(player_id: player.id, team: nil)
    expect(outcome).not_to be_valid
  end

  it "validates team name" do
    outcome = Outcome.new(player_id: player.id, team: 'blue')
    expect(outcome).to be_valid
  end

  it "winner can not be a non-team name" do
    outcome = Outcome.new(player_id: player.id, team: 'silly')
    expect(outcome).not_to be_valid
  end

  it "requires player" do
    player_outcome = Outcome.new(player_id: nil, team: 'red')
    expect(player_outcome).not_to be_valid
  end

  it "validates player id" do
    pending "should validate that an outcome's player id refers to a real player"
    NOT_A_REAL_PLAYER_ID = 0 # todo: make a real player using factories
    outcome = Outcome.new(team: 'blue', player_id: NOT_A_REAL_PLAYER_ID)
    expect(outcome).not_to be_valid
  end

end
