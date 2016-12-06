# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default("f"), not null
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
      let!(:current_season) { Season.current }
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
        betty = create_player(player_name: 'betty', team: 'blue'),
        bob = create_player(player_name: 'bob', team: 'blue'),
        roger = create_player(player_name: 'roger', team: 'red'),
        rita = create_player(player_name: 'rita', team: 'red'),
      ]

      games = []

      player_outcome_base = {
        takedowns: 1,
        throws: 2,
        pickups: 3,
        flag_carry_distance: 4,
      }

      season = Season.current

      num_games = 3
      num_games.times do
        player_outcomes = players.map do |player|
          Outcome.new(({team: player.team,
                        player_id: player.id,
                        captures: player.name == 'betty' ? 1 : 0,
                      } + player_outcome_base).with_indifferent_access)
        end

        game = Game.current

        betty.set_piece(role: 'offense', path: [[0,0]])
        bob.set_piece(role: 'defense', path: [[0,0]])
        roger.set_piece(role: 'offense', path: [[0,0]])
        rita.set_piece(role: 'defense', path: [[0,0]])

        game.lock_game!
        game.finish_game! winner: 'blue',
                          match_length: 100,
                          player_outcomes: player_outcomes
        games << game
      end

      season.reload
      json = season.as_json

      expect(json).to include('team_summaries')

      blue = json['team_summaries'].find { |h| h['team'] == 'blue' }
      expect(blue['captures']).to eq(num_games)
      expect(blue['captures']).to eq(num_games)
      expect(blue['takedowns']).to eq(num_games * player_outcome_base[:takedowns] * 2)
      expect(blue['throws']).to eq(num_games * player_outcome_base[:throws] * 2)
      expect(blue['pickups']).to eq(num_games * player_outcome_base[:pickups] * 2)

      red = json['team_summaries'].find { |h| h['team'] == 'red' }
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
end
