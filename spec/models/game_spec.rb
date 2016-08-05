# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locked     :boolean
#  current    :boolean          default("f")
#
# Indexes
#
#  index_games_on_current  (current)
#

require 'rails_helper'

describe Game, type: :model do

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

      it "has no outcome" do
        game = Game.current
        expect(game.outcome).to be_nil
      end
    end

    context "when there is no current game" do
      before do
        @previous_game = Game.create! current: false

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
      it "returns it" do
        game = Game.current
        expect(Game.current).to eq(game)
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
      game_a = Game.create! current: false
      # todo: use Rails 5 touch method
      game_a.update_columns(updated_at: Time.new(2015, 2, 16, 0, 0, 0))

      game_b = Game.create! current: false
      game_c = Game.create! current: true

      expect(Game.previous).to eq(game_b)
    end
  end

  describe 'winner' do
    it "proxies to outcome" do
      game = Game.current
      game.outcome = Outcome.new(winner: 'red')
      expect(game.winner).to eq('red')
    end

    it "works if there is no outcome yet" do
      game = Game.current
      expect(game.winner).to be_nil
    end
  end

  describe 'lock_game!' do
    before do
      @game = Game.current
    end
    context 'when the game is unlocked' do
      it 'locks it' do
        @game.lock_game!
        expect(@game).to be_locked
      end

      def create_alice_with_piece
        alice = Player.create!(name: 'alice', team: 'blue')
        piece_attributes = {
          body_type: 'female',
          role: 'offense',
          path: '', # todo
        }
        alice.set_piece(piece_attributes)
        return alice
      end

      it "copies all players' pieces" do
        alice = create_alice_with_piece
        @game.lock_game!
        expect(@game.pieces).not_to be_empty
        piece = @game.pieces.first
        expect(piece.player).to eq(alice)
        expect(piece.team).to eq(alice.team)
        expect(piece.body_type).to eq('female')
        expect(piece.role).to eq('offense')
        expect(piece.path).to eq('')
      end

      context 'when there is a player with no piece' do
        it 'ignores it' do
          alice = create_alice_with_piece
          bob = Player.create!(name: 'bob', team: 'blue')
          @game.lock_game! # assert no raise
          expect(@game).to be_locked
          expect(@game.pieces.size).to eq(1)
          piece = @game.pieces.first
          expect(piece.player).to eq(alice)

        end
      end
    end
    context 'when the game is locked' do
      it 'fails' do
        @game.lock_game!
        expect do
          @game.lock_game!
        end.to raise_error(RuntimeError)
      end
    end
  end

  describe "as_json" do
    it "includes outcome and team_outcomes" do
      game = Game.current
      game.outcome = Outcome.new(winner: 'red', team_outcomes: [
        TeamOutcome.new(team: 'blue', takedowns: 2),
        TeamOutcome.new(team: 'red', takedowns: 3),
      ])
      game.save!

      expect(game.as_json['game']['outcome']).to be
      expect(game.as_json['game']['outcome']['winner']).to eq('red')

      expect(game.as_json['game']['outcome']['team_outcomes']).to be
      expect(game.as_json['game']['outcome']['team_outcomes'].size).to eq(2)
      expect(game.as_json['game']['outcome']['team_outcomes'][0]['team']).to eq('blue')
      expect(game.as_json['game']['outcome']['team_outcomes'][0]['takedowns']).to eq(2)
      expect(game.as_json['game']['outcome']['team_outcomes'][1]['team']).to eq('red')
      expect(game.as_json['game']['outcome']['team_outcomes'][1]['takedowns']).to eq(3)
    end
  end

end
