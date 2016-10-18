require 'rails_helper'

describe TeamOutcome do
  it "requires team name" do
    team_outcome = TeamOutcome.new(team: nil, games: nil)
    expect(team_outcome).not_to be_valid
  end

  it "validates team name" do
    team_outcome = TeamOutcome.new(team: 'blue', games: nil)
    expect(team_outcome).to be_valid
  end

  context "given a game" do
    it "adds up stats" do
      player_outcomes = [
        Outcome.new({team: 'blue',
                           takedowns: 1,
                           throws: 2,
                           pickups: 3,
                           flag_carry_distance: 4,
                           captures: 1,
                          }.with_indifferent_access),

        Outcome.new({team: 'red',
                           takedowns: 11,
                           throws: 12,
                           pickups: 13,
                           flag_carry_distance: 14,
                           captures: 0,
                          }.with_indifferent_access),
      ]

      game = Game.new(
        winner: 'blue',
        match_length: 100,
        player_outcomes: player_outcomes
      )
      games = [game]

      team_outcome = TeamOutcome.new(team: 'blue', games: games)
      expect(team_outcome.as_json).to eq({team: 'blue',
                                          captures: 1,
                                          takedowns: 1,
                                          throws: 2,
                                          pickups: 3,
                                          flag_carry_distance: 4,
                                         }.with_indifferent_access)

      team_outcome = TeamOutcome.new(team: 'red', games: games)
      expect(team_outcome.as_json).to eq({team: 'red',
                                          takedowns: 11,
                                          throws: 12,
                                          pickups: 13,
                                          flag_carry_distance: 14,
                                          captures: 0,
                                         }.with_indifferent_access)

    end
  end

  context "given a bunch of games with outcomes" do
    it "adds up stats" do
      games = []
      totals = {'red' => {}, 'blue' => {}}
      player_outcomes = []

      100.times do
        stats = {
          takedowns: rand(10),
          throws: rand(10),
          pickups: rand(10),
          flag_carry_distance: rand(10),
          captures: rand(10),
        }.with_indifferent_access

        team_name = Team::NAMES.values.sample
        stats.each_pair do |stat, val|
          totals[team_name][stat] ||= 0
          totals[team_name][stat] += val
        end

        player_outcomes << Outcome.new({team: team_name} + stats)
      end

      game = Game.new(
        winner: 'blue',
        match_length: 10,
        player_outcomes: player_outcomes
      )

      games << game

      Team::NAMES.values.each do |team_name|
        team_outcome = TeamOutcome.new(team: team_name, games: games)
        expect(team_outcome.as_json).to include(totals[team_name])
      end
    end
  end
end
