# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default(FALSE), not null
#  start_at   :date
#

require 'rails_helper'

describe Season do

  describe "current" do
    context "when there is no season at all" do

      it "creates a current season" do
        season = Season.current
        expect(season).to be_current
      end

      it "has no games" do
        season = Season.current
        expect(season.games).to be_empty
      end

    end

    context "when there is no current season" do
      before do
        @previous_season = Season.create!
      end

      it "creates one" do
        season = Season.current
        expect(season).to be_current
        expect(season).not_to eq(@previous_season)
      end

    end

    context "when there is a current season" do
      let!(:current_season) {Season.current}
      it "returns it" do
        expect(Season.current).to eq(current_season)
      end
    end

    context "if there is more than one current season" do
      it "freaks out" do
        season = Season.current
        expect do
          Season.create! current: true
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

  describe "previous" do
    it "fetches the most recent non-current season" do
      # todo: use state, remove current flag
      season_a = Season.create! current: false
      # todo: use Rails 5 touch method
      season_a.update_columns(updated_at: Time.new(2015, 2, 16, 0, 0, 0))

      season_b = Season.create! current: false
      season_c = Season.create! current: true

      expect(Season.previous).to eq(season_b)
    end
  end

  describe "as_json" do
    it "includes team_summaries and player_summaries" do
      players = [
          betty = create_player(player_name: 'betty', team_name: 'blue'),
          bob = create_player(player_name: 'bob', team_name: 'blue'),
          roger = create_player(player_name: 'roger', team_name: 'red'),
          rita = create_player(player_name: 'rita', team_name: 'red'),
      ]

      games = []

      player_outcome_base = {
          takedowns: 1,
          throws: 2,
          pickups: 3,
          flag_carry_distance: 4,
      }

      season = Season.current
      season.add_all_players # lame, but needed for now

      num_games = 3
      num_games.times do
        player_outcomes = players.map do |player|
          Outcome.new(({team_name: player.team_name,
                        player_id: player.id,
                        captures: player.name == 'betty' ? 1 : 0,
          } + player_outcome_base).with_indifferent_access)
        end

        game = Game.current

        betty.set_piece(role: 'offense', path: [[0, 0]])
        bob.set_piece(role: 'defense', path: [[0, 0]])
        roger.set_piece(role: 'offense', path: [[0, 0]])
        rita.set_piece(role: 'defense', path: [[0, 0]])

        game.lock_game!
        game.finish_game! winner: 'blue',
                          match_length: 100,
                          player_outcomes: player_outcomes
        games << game
      end

      season.reload
      json = season.as_json

      expect(json).to include('team_summaries')

      blue = json['team_summaries'].find {|h| h['team_name'] == 'blue'}
      expect(blue['captures']).to eq(num_games)
      expect(blue['captures']).to eq(num_games)
      expect(blue['takedowns']).to eq(num_games * player_outcome_base[:takedowns] * 2)
      expect(blue['throws']).to eq(num_games * player_outcome_base[:throws] * 2)
      expect(blue['pickups']).to eq(num_games * player_outcome_base[:pickups] * 2)

      red = json['team_summaries'].find {|h| h['team_name'] == 'red'}
      expect(red['captures']).to eq(0)
      expect(red['captures']).to eq(0)
      expect(red['takedowns']).to eq(num_games * player_outcome_base[:takedowns] * 2)
      expect(red['throws']).to eq(num_games * player_outcome_base[:throws] * 2)
      expect(red['pickups']).to eq(num_games * player_outcome_base[:pickups] * 2)

      expect(json).to include('player_summaries')
      expect(json['player_summaries'].size).to eq(4)
      expect(json['player_summaries'][0]).to eq({
                                                    "player_id" => betty.id,
                                                    "takedowns" => 3,
                                                    "throws" => 6,
                                                    "pickups" => 9,
                                                    "captures" => 3,
                                                    "flag_carry_distance" => 12,
                                                    "attack_mvp" => 3,
                                                    "defend_mvp" => 0,
                                                })
      expect(json['player_summaries'][1]).to eq({
                                                    "player_id" => bob.id,
                                                    "takedowns" => 3,
                                                    "throws" => 6,
                                                    "pickups" => 9,
                                                    "captures" => 0,
                                                    "flag_carry_distance" => 12,
                                                    "attack_mvp" => 0,
                                                    "defend_mvp" => 3,
                                                })


    end
  end

  describe "dates" do
    describe "start_at" do
      it "is initialized as the next upcoming Sunday (but can be changed before it starts)" do
        season = Season.create!
        expect(season.start_at).to eq(Chronic.parse("next Sunday").to_date)
      end
    end

    describe "finish_at" do
      it "is set to tomorrow if there's no future seasons" do
        sunday1 = Chronic.parse("01-06-2002").to_date
        season = Season.create!(start_at: sunday1)
        expect(season.finish_at).to eq(Chronic.parse("tomorrow").to_date)
      end

      it "is set to the earliest future season's start_at date" do
        sunday1 = Chronic.parse("01-06-2002").to_date
        season1 = Season.create!(start_at: sunday1)

        sunday2 = sunday1 + 1.month
        season2 = Season.create!(start_at: sunday2)

        sunday3 = sunday2 + 1.month
        season3 = Season.create!(start_at: sunday3)

        expect(season1.finish_at).to eq(sunday2)
        expect(season2.finish_at).to eq(sunday3)
      end
    end

    describe 'timespan' do
      it 'goes from start_at (inclusive) to finish_at (exclusive)' do
        sunday1 = Chronic.parse("01-06-2002").to_date
        season1 = Season.create!(start_at: sunday1)

        sunday2 = sunday1 + 1.month
        season2 = Season.create!(start_at: sunday2)

        expect(season1.timespan).to eq((sunday1...sunday2))

        expect(season1.timespan).to include(sunday1)
        expect(season1.timespan).not_to include(sunday2)
      end
    end
    
    describe 'weekdays' do
      it 'includes all weekdays inside its timespan' do
        sunday1 = Chronic.parse("01-06-2002").to_date
        season1 = Season.create!(start_at: sunday1)
        sunday2 = sunday1 + 2.months
        season2 = Season.create!(start_at: sunday2)

        days = season1.weekdays
        expect(days.size).to eq(42)
        days.each do |day|
          expect(day).to be_weekday
        end
      end
    end
  end

  describe "weeks" do
    it "returns a list of sets of games" do
      start_date = Chronic.parse("2 weeks ago Sunday").to_date
      Timecop.freeze

      season = Season.create! start_at: start_date
      expect(season.start_at).to eq(start_date)

      preseason = [
          Game.create!(season: season, state: 'completed', played_at: start_date - 1.day)
      ]
      first_week = [
          Game.create!(season: season, state: 'completed', played_at: start_date + 11.hours),
          Game.create!(season: season, state: 'completed', played_at: start_date + 1.day + 9.hours),
      ]
      second_week = [
          Game.create!(season: season, state: 'completed', played_at: start_date + 1.week + 12.hours),
          Game.create!(season: season, state: 'completed', played_at: start_date + 1.week + 1.day + 10.hours),
      ]
      third_week = []
      fourth_week = [
          Game.create!(season: season, state: 'completed', played_at: start_date + 3.week + 13.hours),
          Game.create!(season: season, state: 'completed', played_at: start_date + 3.week + 1.day + 11.hours),
      ]

      expect(season.week(0).games).to eq(preseason)
      expect(season.week(1).games).to eq(first_week)
      expect(season.week(2).games).to eq(second_week)
      expect(season.week(3).games).to eq(third_week)
      expect(season.week(4).games).to eq(fourth_week)

      expect(season.weeks.map(&:games)).to eq([
                                                  preseason, first_week, second_week, third_week, fourth_week
                                              ])


    end

    it "works with the game dates on staging (bugfix)" do

      season_start = Date.parse("2017-01-01")
      season = Season.create! start_at: season_start

      Game.create!(season: season, state: 'preparing', played_at: Time.parse("2017-01-05T15:06:34.611-05:00"))
      games = [
          "2016-12-05T16:02:19.058-05:00",
          "2016-11-16T16:02:17.302-05:00",
          "2016-11-22T16:01:21.576-05:00",
          "2016-10-04T09:26:59.408-04:00",
          "2016-10-04T11:39:09.754-04:00",
          "2016-11-16T16:35:29.353-05:00",
          "2016-11-28T16:13:37.871-05:00",
          "2016-12-06T16:54:20.109-05:00",
          "2016-11-16T18:20:37.592-05:00",
          "2016-10-04T13:39:38.560-04:00",
          "2016-11-30T16:01:43.736-05:00",
          "2016-12-13T16:10:18.273-05:00",
          "2016-11-08T16:25:38.077-05:00",
          "2016-11-16T18:26:54.227-05:00",
          "2016-12-01T16:09:09.237-05:00",
          "2016-11-11T09:40:16.515-05:00",
          "2016-12-07T16:06:00.492-05:00",
          "2016-11-17T16:32:42.807-05:00",
          "2016-11-11T16:00:37.688-05:00",
          "2016-12-02T16:01:55.123-05:00",
          "2016-11-14T16:01:18.526-05:00",
          "2016-12-19T09:58:03.215-05:00",
          "2016-11-18T15:32:43.865-05:00",
          "2016-11-15T16:01:14.406-05:00",
          "2016-12-08T16:31:20.328-05:00",
          "2016-12-14T16:15:26.374-05:00",
          "2016-11-21T16:04:22.336-05:00",
          "2016-12-09T16:03:56.998-05:00",
          "2016-12-15T16:01:04.289-05:00",
          "2016-12-19T15:56:55.713-05:00"
      ].map do |iso8601|
        Game.create! season: season, state: 'completed', played_at: Time.parse(iso8601)
      end

      expect(season.week(0).games).to eq(games)
      expect(season.weeks[0].games).to eq(games)

    end
  end

  describe "teams" do
    let!(:betty) {create_player(player_name: 'betty', team_name: 'blue')}
    let!(:bob) {create_player(player_name: 'bob', team_name: 'blue')}
    let!(:roger) {create_player(player_name: 'roger', team_name: 'red')}
    let!(:rita) {create_player(player_name: 'rita', team_name: 'red')}
    # charlie = create_control_group_member(player_name: 'charlie', team_name: 'control')

    it "a newly created season has team members, based off the player's given team" do
      season = Season.create!

      expect(season.team_members('red')).to match_array([roger, rita])
      expect(season.team_members('blue')).to match_array([betty, bob])
    end

    it "add_all_players is idempotent" do
      season = Season.current
      season.add_all_players
      season.add_all_players
      expect(season.team_members('red')).to match_array([roger, rita])
    end

    describe 'switch_team' do
      describe "for an upcoming (non-current) season" do

        let!(:season) {Season.create!}
        it "can switch players between teams" do
          season.switch_team(betty, 'red')
          expect(season.team_members('red')).to match_array([roger, rita, betty])
          expect(season.team_members('blue')).to match_array([bob])
        end

        it 'does not clear the player path setup info' do
          betty.piece.update!(path: "{}")
          season.switch_team(betty, 'red')
          expect(betty.piece.path).not_to be_nil
        end

        it 'does change the player/piece info for the current season' do
          season.switch_team(betty, 'red')
          expect(betty.team_name).to eq('blue')
          expect(betty.piece.team_name).to eq('blue')
        end

        it 'does change the player/piece info when it becomes the current season' do
          season.switch_team(betty, 'red')
          season.start!
          betty.reload
          expect(betty.team_name).to eq('red')
          expect(betty.piece.team_name).to eq('red')
        end

      end

      describe "for the current season" do
        before {Season.current.add_all_players} # :-(
        let!(:season) {Season.current}

        it "can switch players between teams" do
          season.switch_team(betty, 'red')
          expect(season.team_members('red')).to match_array([roger, rita, betty])
          expect(season.team_members('blue')).to match_array([bob])
        end

        it 'clears the player path setup info' do
          betty.piece.update!(path: "{}")
          season.switch_team(betty, 'red')
          expect(betty.piece.path).to be_nil
        end

        it 'does not change the player/piece info for the current season' do
          season.switch_team(betty, 'red')
          expect(betty.team_name).to eq('blue')
          expect(betty.piece.team_name).to eq('blue')
        end
      end
    end


  end

  describe "start!" do
    let!(:initial_season) {Season.current}
    let!(:season) {Season.create!}

    before {season.start!}

    it 'makes this season current' do
      expect(season.reload).to be_current
    end

    it 'makes the other season not current' do
      expect(initial_season.reload).not_to be_current
    end
  end

end
