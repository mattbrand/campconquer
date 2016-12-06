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

RSpec.describe Summary, type: :model do

  context "even an empty tally" do
    it "has zeroes not nulls" do
      x = Summary.new(games: [])
      x.as_json.each_pair do |stat, value|
        expect(value).to eq(0)
      end
    end
  end

  context "given a game" do
    it "adds up stats" do
      player_outcomes = [
          Outcome.new({team: 'blue',
                       player_id: 100,
                       takedowns: 1,
                       throws: 2,
                       pickups: 3,
                       captures: 1,
                       flag_carry_distance: 4,
                       attack_mvp: true,
                      }.with_indifferent_access),

          Outcome.new({team: 'red',
                       player_id: 200,
                       takedowns: 10,
                       throws: 20,
                       pickups: 30,
                       captures: 0,
                       flag_carry_distance: 40,
                       defend_mvp: true,
                      }.with_indifferent_access),
      ]

      game = Game.new(winner: 'blue',
                      match_length: 100,
                      player_outcomes: player_outcomes)
      summary = Summary.new(games: [game])

      expect(summary.as_json).to eq({
                                                takedowns: 11,
                                                throws: 22,
                                                pickups: 33,
                                                captures: 1,
                                                flag_carry_distance: 44,
                                                attack_mvp: 1,
                                                defend_mvp: 1,

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
            attack_mvp: rand(2) == 0 ? false : true,
            defend_mvp: rand(2) == 0 ? false : true,
        }.with_indifferent_access

        stats.each_pair do |stat, val|
          totals[stat] ||= 0
          val = 1 if val == true
          val = 0 if val == false
          totals[stat] += val
        end

        player_outcomes << Outcome.new(stats)
      end

      game = Game.new(
          winner: 'blue',
          match_length: 10,
          player_outcomes: player_outcomes
      )

      games << game

      summary = Summary.new(games: games)
      expect(summary.as_json).to include(totals)
    end
  end

end
