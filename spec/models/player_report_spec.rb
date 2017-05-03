require 'rails_helper'

describe PlayerReport do

  let(:sunday) {Chronic.parse("Sunday").to_date}
  let(:monday) {sunday + 1.day}
  let(:tuesday) {sunday + 2.days}
  let(:wednesday) {sunday + 3.days}

  let(:next_sunday) {sunday + 1.week}

  let(:previous_sunday) {sunday - 1.week}
  let(:previous_monday) {previous_sunday + 1.day}

  let(:next_sunday) {sunday + 1.week}
  let(:next_monday) {next_sunday + 1.day}

  let(:timespan) {Timespan.new(sunday, next_sunday)}

  it "calculates whether they were control or game group" do
    player = Player.new(team_name: "control")
    report = player.report(timespan)
    expect(report.control_group).to eq(true)

    player = Player.new(team_name: "red")
    report = player.report(timespan)
    expect(report.control_group).to eq(false)
  end

  describe 'activity measures' do
    let(:player) {Player.create!(name: 'Moby', team_name: "red")}

    before do
      hit = {steps: 100, active_minutes: Player::GOAL_MINUTES}
      miss = {steps: 1, active_minutes: 1}

      # some hits that will not be counted cause they're on a different span
      player.set_activity_for(previous_monday, hit)
      player.set_activity_for(next_monday, hit)

      # a hit that will not be counted cause it's on a weekend
      player.set_activity_for(sunday, hit)

      player.set_activity_for(monday, hit)
      player.set_activity_for(tuesday, miss)
      player.set_activity_for(wednesday, hit)
    end

    it "calculates number of times a user hit their daily active minutes (weekdays only)" do
      expect(player.report(timespan).activity_goal_reached).to eq(2)
    end

    it "calculates Average # of steps taken per day (weekdays only)" do
      expect(player.report(timespan).mean_steps_per_day).to eq((100 + 100 + 1)/5.0)
    end

    it "calculates Average # of active minutes per day (weekdays only)" do
      expect(player.report(timespan).mean_active_minutes_per_day).to eq((Player::GOAL_MINUTES + Player::GOAL_MINUTES + 1)/5.0)
    end

    it "calculates Average # of steps taken per week (weekdays only)"
    it "calculates Average # of active minutes per week (weekdays only)"

    def run_game(alice, season, setup)
      game = Game.current
      alice.set_piece(path: setup)
      game.lock_game!
      game.finish_game!
      season.reload
    end

    it "calculates number of games participated in (if game group) (through whole season)" do
      season = Season.current
      alice = create_alice_with_piece
      good_setup = [[0, 0]]
      no_setup = nil

      run_game(alice, season, good_setup)
      expect(PlayerReport.new(player: alice, season: season).games_played).to eq(1)

      run_game(alice, season, good_setup)
      expect(PlayerReport.new(player: alice, season: season).games_played).to eq(2)

      run_game(alice, season, no_setup)
      expect(PlayerReport.new(player: alice, season: season).games_played).to eq(2)
    end

    describe 'CSV' do
      it 'gives us some values' do
        report = player.report(timespan)
        expect(report.values).to eq(
                                     [player.id,
                                      player.name,
                                      false,
                                      report.games_played,
                                      report.activity_goal_reached,
                                      report.mean_steps_per_day,
                                      report.mean_active_minutes_per_day]
                                 )
      end

    end

  end

end
