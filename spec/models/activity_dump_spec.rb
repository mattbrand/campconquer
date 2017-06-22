require 'rails_helper'

def expect_field_value(field_name, expected_value)
  expect(dump.values[dump.headers.index(field_name)]).to eq(expected_value)
end

describe ActivityDump do

  let(:week1) { Week.new(start_at: Chronic.parse("Sunday").to_date, number: 0) }
  let(:week2) { Week.new(start_at: week1.finish_at, number: 0) }

  let(:alice) { create_alice_with_piece }
  let(:season) { Season.current }

  describe 'when empty' do

    let(:activity) { Activity.new(date: week1.monday, player: alice) }
    let(:dump) { ActivityDump.new(season: season, activity: activity) }

    it 'has headers' do
      expect(dump.headers).to include('season_id')
      expect(dump.headers).to include('activity_id')
    end

    it 'has a season and an activity' do
      expect(dump.season_id).to eq(season.id)
      expect(dump.activity_id).to eq(activity.id)
    end

    it 'has values' do
      expect_field_value('season_id', season.id)
      expect_field_value('player_id', alice.id)
      expect_field_value('player_name', alice.name)
      expect_field_value('date', activity.date)
      # todo: more fields?
    end

  end

  describe 'control_group' do
    it "calculates if they were control group" do
      player = Player.new(team_name: "control")
      activity = Activity.new(date: week1.monday, player: player)
      dump = ActivityDump.new(season: season, activity: activity)
      expect(dump.control_group).to eq(true)
    end

    it "calculates if they were game group" do
      player = Player.new(team_name: "red")
      activity = Activity.new(date: week1.monday, player: player)
      dump = ActivityDump.new(season: season, activity: activity)
      expect(dump.control_group).to eq(false)
    end
  end

  describe 'games_played' do
    it 'counts the number of games this season in which this player had a piece'
  end

  # describe 'activity measures' do
  #   let(:player) {Player.create!(name: 'Moby', team_name: "red")}
  #
  #   before do
  #     hit = {steps: 100, active_minutes: Player::GOAL_MINUTES}
  #     miss = {steps: 1, active_minutes: 1}
  #
  #     # some hits that will not be counted cause they're on a different span
  #     player.set_activity_for(previous_monday, hit)
  #     player.set_activity_for(next_monday, hit)
  #
  #     # a hit that will not be counted cause it's on a weekend
  #     player.set_activity_for(sunday, hit)
  #
  #     player.set_activity_for(monday, hit)
  #     player.set_activity_for(tuesday, miss)
  #     player.set_activity_for(wednesday, hit)
  #   end
  #
  #   it "calculates number of times a user hit their daily active minutes (weekdays only)" do
  #     expect(player.report(timespan).activity_goal_reached).to eq(2)
  #   end
  #
  #   it "calculates Average # of steps taken per day (weekdays only)" do
  #     expect(player.report(timespan).mean_steps_per_day).to eq((100 + 100 + 1)/5.0)
  #   end
  #
  #   it "calculates Average # of active minutes per day (weekdays only)" do
  #     expect(player.report(timespan).mean_active_minutes_per_day).to eq((Player::GOAL_MINUTES + Player::GOAL_MINUTES + 1)/5.0)
  #   end
  #
  #   it "calculates Average # of steps taken per week (weekdays only)"
  #   it "calculates Average # of active minutes per week (weekdays only)"
  #
  #   def run_game(alice, season, setup)
  #     game = Game.current
  #     alice.set_piece(path: setup)
  #     game.lock_game!
  #     game.finish_game!
  #     season.reload
  #   end
  #
  #   it "calculates number of games participated in (if game group) (through whole season)" do
  #     season = Season.current
  #     alice = create_alice_with_piece
  #     good_setup = [[0, 0]]
  #     no_setup = nil
  #
  #     run_game(alice, season, good_setup)
  #     expect(PlayerDump.new(player: alice, season: season).games_played).to eq(1)
  #
  #     run_game(alice, season, good_setup)
  #     expect(PlayerDump.new(player: alice, season: season).games_played).to eq(2)
  #
  #     run_game(alice, season, no_setup)
  #     expect(PlayerDump.new(player: alice, season: season).games_played).to eq(2)
  #   end
  #
  #   describe 'CSV' do
  #     it 'gives us some values' do
  #       report = player.report(timespan)
  #       expect(report.values).to eq(
  #                                    [player.id,
  #                                     player.name,
  #                                     false,
  #                                     report.games_played,
  #                                     report.activity_goal_reached,
  #                                     report.mean_steps_per_day,
  #                                     report.mean_active_minutes_per_day]
  #                                )
  #     end
  #
  #   end
  #
  # end
end
