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

  let(:timespan) {(sunday..next_sunday)}

  it "calculates whether they were control or game group" do
    player = Player.new(team_name: "control")
    report = player.report(timespan)
    expect(report.control_group).to eq(true)

    player = Player.new(team_name: "red")
    report = player.report(timespan)
    expect(report.control_group).to eq(false)
  end

  describe 'activity measures' do
    let(:player) {Player.create!(team_name: "red")}
    it "calculates number of times a user hit their daily active minutes (weekdays only) (through whole season)" do

      hit = {steps: 100, active_minutes: Player::GOAL_MINUTES + 1}
      miss = {steps: 1, active_minutes: Player::GOAL_MINUTES - 1}

      # some hits that will not be counted cause they're on a different span
      player.set_activity_for(previous_monday, hit)
      player.set_activity_for(next_monday, hit)

      # a hit that will not be counted cause it's on a weekend
      player.set_activity_for(sunday, hit)

      player.set_activity_for(monday, hit)
      player.set_activity_for(tuesday, miss)
      player.set_activity_for(wednesday, hit)

      ap timespan
      expect(player.report(timespan).active_weekdays).to eq(2)

    end

    it "calculates Average # of steps taken (per day, week) (weekdays only)"
    it "calculates Average # of active minutes (per day, week) (weekdays only)"


    it "calculates number of games were participated in (if game group) (through whole season)" do

    end
  end


end
