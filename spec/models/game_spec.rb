# == Schema Information
#
# Table name: games
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  locked       :boolean
#  current      :boolean          default("f")
#  season_id    :integer
#  state        :string           default("preparing")
#  moves        :text
#  winner       :string
#  match_length :integer
#
# Indexes
#
#  index_games_on_current    (current)
#  index_games_on_season_id  (season_id)
#

require 'rails_helper'

describe Game do


  # todo: move to a fixture factory
  def create_alice_with_piece
    create_player(player_name: 'alice' 'female', team: 'blue')
  end

  def create_player(player_name:, team: 'red',
                    body_type: 'female',
                    role: 'defense',
                    coins: 100)
    player = Player.create!(name: player_name, team: team, coins: coins)
    piece_attributes = {
      body_type: body_type,
      role: role,
      path: [[0, 0]]
    }
    player.set_piece(piece_attributes)
    player
  end

  let(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes') }
  let(:tee_shirt) { Gear.create!(name: 'tee-shirt', gear_type: 'shirt') }

  describe "current" do
    context "when there is no game at all" do

      it "creates an unlocked current game" do
        game = Game.current
        expect(game).to be_current
        expect(game).not_to be_locked
      end

      it "has no pieces" do
        game = Game.current
        expect(game.pieces).to be_empty
      end

      it "has no winner" do
        game = Game.current
        expect(game.winner).to be_nil
      end

      it "has a season" do
        game = Game.current
        expect(game.season).not_to be_nil
        expect(game.season).to eq(Season.current)
      end
    end

    context "when there is no current game" do
      before do
        @previous_game = Game.create! state: 'completed'

        # todo: better piece factory, including player etc
        @previous_game.pieces.create! team: 'blue'
      end

      it "creates one" do
        game = Game.current
        expect(game).to be_current
        expect(game).not_to be_locked
        expect(game).not_to eq(@previous_game)
      end
    end

    context "when there is a current game" do
      let!(:current_game) { Game.current }
      it "returns it" do
        expect(Game.current).to eq(current_game)
      end
    end

    context "if there is more than one current game" do
      it "freaks out" do
        game = Game.current
        expect do
          Game.create! current: true
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

  describe "previous" do
    it "fetches the most recent non-current game" do
      # todo: use state, remove current flag
      game_a = Game.create! current: false
      # todo: use Rails 5 touch method
      game_a.update_columns(updated_at: Time.new(2015, 2, 16, 0, 0, 0))

      game_b = Game.create! current: false
      game_c = Game.create! current: true

      expect(Game.previous).to eq(game_b)
    end
  end

  describe 'lock_game!' do

    let!(:current_game) { Game.current }

    context 'when the game is unlocked' do
      it 'locks it' do
        current_game.lock_game!
        expect(current_game).to be_locked
      end

      it "copies a player's pieces" do
        alice = create_alice_with_piece
        old_piece = alice.piece

        current_game.lock_game!
        expect(current_game.pieces).not_to be_empty

        piece = current_game.pieces.first
        expect(piece.game).to eq(current_game)
        expect(piece.player).to eq(alice)
        expect(piece.team).to eq(alice.team)
        expect(piece.body_type).to eq('female')
        expect(piece.role).to eq('defense')
        expect(piece.path).to eq([Point.new(x: 0, y: 0)])

        expect(alice.reload.piece).to eq(old_piece)
      end


      it "copies a player's items" do
        alice = create_alice_with_piece

        alice.piece.items.create!(gear_id: tee_shirt.id, equipped: false)
        alice.piece.items.create!(gear_id: galoshes.id, equipped: true)

        alice.piece.items.reload # Rails is silly

        expect(alice.piece.gear_equipped).to eq(['galoshes'])
        expect(alice.piece.gear_owned).to include('galoshes', 'tee-shirt')

        current_game.lock_game!

        copied_piece = current_game.pieces.find_by(player_id: alice.id)
        copied_piece.items.reload

        expect(copied_piece.gear_equipped).to eq(['galoshes'])
        expect(copied_piece.gear_owned).to include('galoshes', 'tee-shirt')

        # make sure it's a copy, not the original item
        expect(copied_piece.items).not_to include(galoshes)
        expect(copied_piece.items).not_to include(tee_shirt)
      end

      it "copies all players' pieces and items" do
        3.times do
          p = create_player(player_name: Faker::Name.first_name)
          p.buy_gear!(galoshes.name)
          p.buy_gear!(tee_shirt.name)
          p.equip_gear!(galoshes.name)
        end

        current_game.lock_game!

        current_game.pieces.each do |piece|
          piece.reload
          expect(piece.gear_equipped).to eq(['galoshes'])
          expect(piece.gear_owned).to match_array(['galoshes', 'tee-shirt'])
        end
      end

      context 'when there is a player with no piece' do
        it 'ignores it' do
          alice = create_alice_with_piece
          bob = Player.create!(name: 'bob', team: 'blue')
          current_game.lock_game! # assert no raise
          expect(current_game).to be_locked
          expect(current_game.pieces.size).to eq(1)
          piece = current_game.pieces.first
          expect(piece.player).to eq(alice)
        end
      end

      it 'only copies one piece per player (not old games) (bug)' do
        alice = create_alice_with_piece
        current_game.lock_game!
        expect(current_game.pieces.count).to eq(1)

        current_game.finish_game! winner: 'red' # todo: abort_game! ?
        current_game = Game.current
        current_game.lock_game!
        expect(current_game.pieces.count).to eq(1)
      end
    end

    context 'when the game is locked' do
      it 'fails' do
        current_game.lock_game!
        expect do
          current_game.lock_game!
        end.to raise_error(StateMachine::InvalidTransition)
      end
    end
  end

  describe "as_json" do
    it "includes outcome and team_outcomes" do
      alice = Player.create!(name: 'alice', team: 'blue')
      bob = Player.create!(name: 'bob', team: 'red')

      game = Game.current
      game.lock_game!
      game.finish_game! winner: 'red',
                        player_outcomes_attributes: [# rails is weird
                          {player_id: alice.id, team: 'blue', takedowns: 2},
                          {player_id: bob.id, team: 'red', takedowns: 3},
                        ]

      json = game.as_json
      expect(json['winner']).to eq('red')
      expect(json['team_outcomes']).to be
      expect(json['player_outcomes']).to be
      expect(json['player_outcomes'].size).to eq(2)
      expect(json['player_outcomes'][0]['team']).to eq('blue')
      expect(json['player_outcomes'][0]['takedowns']).to eq(2)
      expect(json['player_outcomes'][1]['team']).to eq('red')
      expect(json['player_outcomes'][1]['takedowns']).to eq(3)
    end
  end

  describe 'finish_game!' do
    let!(:current_game) { Game.current }

    context 'on an unlocked game' do
      it 'does not work on an unlocked game' do
        expect(current_game.state).to eq('preparing')
        expect do
          current_game.finish_game! winner: 'red'
        end.to raise_error("can only finish in_progress games but this game is 'preparing'")
      end
    end

    context 'on a locked (in_progress) game' do
      before { current_game.lock_game! }
      let!(:bob) { Player.create! name: 'bob', team: 'blue' }
      let!(:rhoda) { Player.create! name: 'rhoda', team: 'red' }

      it 'accepts outcome params' do
        current_game.finish_game! winner: 'blue',
                                  player_outcomes_attributes: [# rails is weird http://stackoverflow.com/a/8719885/190135
                                    {
                                      team: 'blue',
                                      player_id: bob.id,
                                      takedowns: 2,
                                      throws: 3,
                                      pickups: 4,
                                      flag_carry_distance: 5,
                                      captures: 6,
                                      attack_mvp: true,
                                      defend_mvp: false,
                                    },
                                    {
                                      team: 'red',
                                      player_id: rhoda.id,
                                      takedowns: 12,
                                      throws: 13,
                                      pickups: 14,
                                      flag_carry_distance: 15,
                                      captures: 16,
                                      attack_mvp: false,
                                      defend_mvp: true,
                                    }
                                  ]

        expect(current_game.winner).to eq('blue')
      end

      it 'accepts a moves list' do
        current_game.finish_game! winner: 'blue',
                                  moves: "SOMEMOVESINASTRING"
        current_game.reload
        expect(current_game.moves).to eq("SOMEMOVESINASTRING")
      end

      it 'changes the state to "completed"' do
        current_game.finish_game! winner: 'blue'
        expect(current_game.state).to eq('completed')
      end
    end
  end

end
