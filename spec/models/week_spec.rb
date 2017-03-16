require 'rails_helper'

describe Week do


  # The week includes Monday to Friday, not Saturday or Sunday.
  # The players who have worn their fitbit more should have a
  # higher probability of their name being drawn. If they wore
  # their fitbit on the first day, their name should be entered
  # into the drawing once, if they wore their fitbit 5 days, they
  # should be entered into the drawing 5 times.

  def activity_on date
    Activity.new(date: date, steps: 1)
  end

  def player_active_on(*active_dates)
    double("Player", activities: active_dates.map { |date| activity_on(date) })
  end

  let(:some_sunday) { Date.parse('2017-01-01') }
  let(:monday) { some_sunday + 1.day }
  let(:tuesday) { some_sunday + 2.days }

  describe 'physically active players' do
    let(:week) { Week.new number: 1, start_at: some_sunday }

    it 'includes those with activity inside the week' do
      player = player_active_on(monday)
      expect(week.physically_active_players([player])).to eq([player])
    end

    it 'excludes those with activity outside the week' do
      player = player_active_on(monday + 1.week)
      expect(week.physically_active_players([player])).to eq([])
    end

    it 'excludes those with activity inside the weekend' do
      player = player_active_on(some_sunday)
      expect(week.physically_active_players([player])).to eq([])
    end

    it 'dupes those with activity on several days' do
      player = player_active_on(monday, tuesday)
      expect(week.physically_active_players([player])).to eq([player, player])
    end
  end

  describe 'game players' do

    let(:alice) { player_active_on(monday) }
    let(:bob) { player_active_on(tuesday) }

    it 'includes those who played one game' do
      game1 = double("Game", players: [alice])
      game2 = double("Game", players: [bob])
      week = Week.new number: 1, start_at: some_sunday, games: [game1, game2]
      expect(week.game_players).to eq([alice, bob])
    end

    it 'includes those who played more than one game' do
      game1 = double("Game", players: [alice])
      game2 = double("Game", players: [alice, bob])
      week = Week.new number: 1, start_at: some_sunday, games: [game1, game2]
      expect(week.game_players).to eq([alice, alice, bob])
    end
  end


end
