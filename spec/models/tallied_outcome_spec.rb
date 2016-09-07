# == Schema Information
#
# Table name: tallied_outcomes
#
#  id         :integer          not null, primary key
#  team       :string
#  takedowns  :integer
#  throws     :integer
#  pickups    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  outcome_id :integer
#
# Indexes
#
#  index_tallied_outcomes_on_outcome_id  (outcome_id)
#

require 'rails_helper'

RSpec.describe TalliedOutcome, type: :model do
  context "given a game" do
    it "adds up stats" do
      player_outcomes = [
        PlayerOutcome.new({team: 'blue',
                           player_id: 100,
                           takedowns: 1,
                           throws: 2,
                           pickups: 3,
                           captures: 1,
                           flag_carry_distance: 4,
                          }.with_indifferent_access),

        PlayerOutcome.new({team: 'red',
                           player_id: 200,
                           takedowns: 10,
                           throws: 20,
                           pickups: 30,
                           captures: 0,
                           flag_carry_distance: 40,
                          }.with_indifferent_access),
      ]

      outcome = Outcome.new(
        winner: 'blue',
        match_length: 100,
        player_outcomes: player_outcomes
      )
      game = Game.new(outcome: outcome)
      tallied_outcome = TalliedOutcome.new(games: [game])

      expect(tallied_outcome.as_json).to eq({
                                          takedowns: 11,
                                          throws: 22,
                                          pickups: 33,
                                          captures: 1,
                                          flag_carry_distance: 44,
                                         }.with_indifferent_access)

    end
  end

  context "given a bunch of games with outcomes" do
    it "adds up stats" do
      games = []
      totals = {}
      player_outcomes = []

      100.times do
        stats = {
          takedowns: rand(10),
          throws: rand(10),
          pickups: rand(10),
          flag_carry_distance: rand(10),
          captures: rand(10),
        }.with_indifferent_access

        stats.each_pair do |stat, val|
          totals[stat] ||= 0
          totals[stat] += val
        end

        player_outcomes << PlayerOutcome.new(stats)
      end

      outcome = Outcome.new(
        winner: 'blue',
        match_length: 10,
        player_outcomes: player_outcomes
      )
      game = Game.new(outcome: outcome)

      games << game

      tallied_outcome = TalliedOutcome.new(games: games)
      expect(tallied_outcome.as_json).to include(totals)
    end
  end
end
