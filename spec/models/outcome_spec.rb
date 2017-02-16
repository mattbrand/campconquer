# == Schema Information
#
# Table name: outcomes
#
#  id                  :integer          not null, primary key
#  team_name           :string
#  takedowns           :integer
#  throws              :integer
#  pickups             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  player_id           :integer
#  flag_carry_distance :integer          not null
#  captures            :integer          not null
#  game_id             :integer
#  attack_mvp          :boolean          default(FALSE), not null
#  defend_mvp          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_outcomes_on_game_id    (game_id)
#  index_outcomes_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Outcome, type: :model do

  let!(:player) { create_player player_name: 'alice', team_name: 'red' }

  it "requires a team" do
    outcome = Outcome.new(player_id: player.id, team_name: nil)
    expect(outcome).not_to be_valid
  end

  it "validates team name" do
    outcome = Outcome.new(player_id: player.id, team_name: 'blue')
    expect(outcome).to be_valid
  end

  it "winner can not be a non-team name" do
    outcome = Outcome.new(player_id: player.id, team_name: 'silly')
    expect(outcome).not_to be_valid
  end

  it "requires player" do
    player_outcome = Outcome.new(player_id: nil, team_name: 'red')
    expect(player_outcome).not_to be_valid
  end

  it "validates player id" do
    NOT_A_REAL_PLAYER_ID = -99
    outcome = Outcome.new(team_name: 'blue', player_id: NOT_A_REAL_PLAYER_ID)
    expect(outcome).not_to be_valid
    expect do
      outcome.save! # in case we decide to use db constraints instead of app validation
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "json" do
    it "includes attack_mvp and defend_mvp" do
      hash = Outcome.new.as_json
      expect(hash).to include({"attack_mvp" => false})
      expect(hash).to include({"defend_mvp" => false})
    end
  end

end
