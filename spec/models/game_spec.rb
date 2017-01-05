# == Schema Information
#
# Table name: games
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  current         :boolean          default("f")
#  season_id       :integer
#  state           :string           default("preparing")
#  moves           :text
#  winner          :string
#  match_length    :integer          default("0"), not null
#  scheduled_start :datetime
#  mvps            :text
#
# Indexes
#
#  index_games_on_current    (current)
#  index_games_on_season_id  (season_id)
#

require 'rails_helper'

describe Game do

  let(:galoshes) { Gear.new(name: 'galoshes', gear_type: 'shoes') }
  let(:tee_shirt) { Gear.new(name: 'tee-shirt', gear_type: 'shirt') }
  before { Gear.all = [galoshes, tee_shirt] }
  after { Gear.reset }

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

      it "sets its start time" do
        someday = Time.zone.local(2008, 6, 1, 11, 0, 0)
        expect(Game).to receive(:next_game_time).and_return(someday)
        game = Game.current
        expect(game.scheduled_start).to eq(someday)
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

  describe 'scheduled start time' do
    def check_time(current_time, expected_next_time)
      Timecop.freeze(current_time) do
        expect(Game.next_game_time).to eq(expected_next_time)
      end
    end

    winter_month = 1
    summer_month = 8

    def local_time(year: 2008, month: 1, day: 1, hour: 0, minute: 0, second: 0)
      Time.zone.local(year, month, day, hour, minute, second)
    end

    it "at midnight, forwards to 11" do
      check_time(local_time(month: winter_month, hour: 0), local_time(month: winter_month, hour: 11))
      check_time(local_time(month: summer_month, hour: 0), local_time(month: summer_month, hour: 11))
    end

    it "before 11, forwards to 11" do
      check_time(local_time(month: winter_month, hour: 10, minute: 59), local_time(month: winter_month, hour: 11))
      check_time(local_time(month: summer_month, hour: 10, minute: 59), local_time(month: summer_month, hour: 11))
    end

    it "at 11, forwards to 4" do
      check_time(local_time(month: winter_month, hour: 11), local_time(month: winter_month, hour: 16))
      check_time(local_time(month: summer_month, hour: 11), local_time(month: summer_month, hour: 16))
    end

    it "at 4, forwards to 11 the next day" do
      check_time(local_time(month: winter_month, hour: 16), local_time(month: winter_month, day: 2, hour: 11))
      check_time(local_time(month: summer_month, hour: 16), local_time(month: summer_month, day: 2, hour: 11))
    end

    it "after 4, forwards to 11 the next day" do
      check_time(local_time(month: winter_month, hour: 16, minute: 1), local_time(month: winter_month, day: 2, hour: 11))
      check_time(local_time(month: summer_month, hour: 16, minute: 1), local_time(month: summer_month, day: 2, hour: 11))
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

        alice.piece.items.create!(gear_name: tee_shirt.name, equipped: false)
        alice.piece.items.create!(gear_name: galoshes.name, equipped: true)

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
        names = []
        10.times do
          names << Faker::Name.first_name
        end
        names.uniq!

        3.times do
          player = create_player(player_name: names.pop)
          player.buy_gear!(galoshes.name)
          player.buy_gear!(tee_shirt.name)
          player.equip_gear!(galoshes.name)
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
          bob = create_player(player_name: 'bob', team: 'blue')
          bob.piece.destroy! # this is a little weird now that pieces are always created
          current_game.lock_game! # assert no raise
          expect(current_game).to be_locked
          expect(current_game.pieces.size).to eq(1)
          piece = current_game.pieces.first
          expect(piece.player).to eq(alice)
        end
      end

      context 'when there is a player with no path' do
        it 'ignores it' do
          alice = create_alice_with_piece
          alice.piece.update!(path: nil) # just making sure
          current_game.lock_game! # assert no raise
          expect(current_game).to be_locked
          expect(current_game.pieces.size).to eq(0)
        end
      end

      it 'only copies one piece per player (not old games) (bug)' do
        alice = create_alice_with_piece
        alice.set_piece(path: [[0, 0]])
        current_game.lock_game!
        expect(current_game.pieces.count).to eq(1)

        current_game.finish_game!

        current_game = Game.current
        alice.set_piece(path: [[0, 0]])
        current_game.lock_game!
        expect(current_game.pieces.count).to eq(1)
      end
    end

    context 'when the game is locked (in progress)' do
      it 'fails' do
        current_game.lock_game!
        expect do
          current_game.lock_game!
        end.to raise_error(StateMachine::InvalidTransition)
      end
    end
  end

  describe "as_json" do

    let!(:alice) { create_player(player_name: 'alice', team: 'blue') }
    let!(:bob) { create_player(player_name: 'bob', team: 'red') }

    let!(:alices_path) { Path.where(team: alice.team, role: alice.role).sample }

    let(:game) { Game.current }

    before do
      alice.set_piece(path: alices_path.points)

      game.lock_game!
      game.finish_game! winner: 'red',
                        player_outcomes_attributes: [# rails is weird
                          {player_id: alice.id, team: 'blue', takedowns: 2},
                          {player_id: bob.id, team: 'red', takedowns: 3, captures: 1},
                        ]

    end

    it "includes outcome and team_summaries" do
      json = game.as_json
      expect(json['winner']).to eq('red')
      expect(json['scheduled_start']).to be
      expect(json['scheduled_start']).to eq(Game.next_game_time.iso8601) # this may fail if run precisely at 11:00 or 16:00
      expect(json['team_summaries']).to be
      expect(json['player_outcomes']).to be
      expect(json['player_outcomes'].size).to eq(2)
      expect(json['player_outcomes'][0]['team']).to eq('blue')
      expect(json['player_outcomes'][0]['takedowns']).to eq(2)
      expect(json['player_outcomes'][1]['team']).to eq('red')
      expect(json['player_outcomes'][1]['takedowns']).to eq(3)
    end

    def strip_key!(hash, key)
      hash.each_pair { |_, val| hash[key] = nil }
      hash
    end

    it "includes paths" do
      json = game.as_json
      expect(json).to include('paths')
      json_paths = json['paths']
      json_paths.map { |p| strip_key!(p, 'count') }
      Path.all.each do |path|
        json = path.as_json
        json['count'] = nil
        expect(json_paths).to include(json)
      end
    end

    it "includes path counts" do
      json = game.as_json
      expect(json).to include('paths')
      counts = json['paths'].map { |p| p['count'] }
      expect(counts).to include(1)
    end

    it "includes mvps under their teams" do
      game_mvps = game.mvps
      json = game.as_json
      Team::GAME_TEAMS.values.each do |team_name|
        team_json = json['team_summaries'].detect { |h| h['team'] == team_name }
        expect(team_json['attack_mvps']).to eq(game_mvps[team_name]['attack_mvps'])
        expect(team_json['defend_mvps']).to eq(game_mvps[team_name]['defend_mvps'])
      end
    end

    it "includes 'locked' (same as state==in_progress)" do
      json = game.as_json
      expect(json['locked']).to eq(false)

      game.state = :in_progress
      json = game.as_json
      expect(json['locked']).to eq(true)
    end
  end

  describe 'paths' do

    let(:red_offense_path) { Path.where(team: 'red', role: 'offense').first }
    let(:red_defense_path) { Path.where(team: 'red', role: 'offense').first }
    let(:blue_offense_path) { Path.where(team: 'blue', role: 'defense').first }
    let(:blue_defense_path) { Path.where(team: 'blue', role: 'defense').first }

    let(:some_paths) { [
      red_offense_path,
      red_defense_path,
      blue_offense_path,
      blue_defense_path,
    ]
    }

    before do
      some_paths.each do |p|
        expect(p).not_to be_nil
      end
    end

    it 'includes all known paths' do
      game = Game.current
      game_paths = game.paths
      Path.all.each do |path|
        expect(game_paths).to include(path)
      end
    end

    it 'includes counts' do
      alice = create_alice_with_piece
      alice.set_piece(path: blue_defense_path.points) # todo: resolve "path" vs "points" ambiguity
      game = Game.current
      game_paths = game.paths
      game_path = game_paths.detect { |p| p == blue_defense_path }
      expect(game_path.count).to eq(1)
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

      let!(:bob) { create_player player_name: 'bob', team: 'blue' }
      let!(:rhoda) { create_player player_name: 'rhoda', team: 'red' }

      before do
        bob.set_piece(role: 'offense', path: '[{"x": 1}, {"y": 2}]', ammo: ['balloon'])
        rhoda.set_piece(role: 'defense', path: '[{"x": 3}, {"y": 4}]', ammo: ['balloon'])
        current_game.lock_game!
      end

      let(:player_outcomes_hashes) { [
        {
          team: 'blue',
          player_id: bob.id,
          takedowns: 2,
          throws: 3,
          pickups: 4,
          flag_carry_distance: 5,
          captures: 1,
          ammo: ['balloon'],
        },
        {
          team: 'red',
          player_id: rhoda.id,
          takedowns: 12,
          throws: 13,
          pickups: 14,
          flag_carry_distance: 15,
          captures: 0,
        }
      ]
      }

      it 'accepts outcome params' do
        current_game.finish_game! player_outcomes_attributes: player_outcomes_hashes # rails is weird http://stackoverflow.com/a/8719885/190135
        expect(current_game.winner).to eq('blue')
      end

      it 'accepts a moves list' do
        current_game.finish_game! moves: "SOMEMOVESINASTRING"
        current_game.reload
        expect(current_game.moves).to eq("SOMEMOVESINASTRING")
      end

      it 'changes the state to "completed"' do
        current_game.finish_game!
        expect(current_game.state).to eq('completed')
      end

      it "calculates winner if it's not passed in" do
        current_game.finish_game! player_outcomes_attributes: player_outcomes_hashes
        expect(current_game.winner).to eq('blue')
      end

      it 'validates winner' do
        expect do
          current_game.finish_game! winner: 'red',
                                    player_outcomes_attributes: player_outcomes_hashes
        end.to raise_error(Game::WinnerMismatch)
      end

      describe 'when there is no winner' do
        before do
          player_outcomes_hashes.first[:captures] = 0
        end
        it 'converts "none" into "nil" winner' do
          current_game.finish_game! winner: 'none',
                                    player_outcomes_attributes: player_outcomes_hashes
          expect(current_game.winner).to eq(nil)
        end
      end

      context 'when no outcomes are passed' do
        it 'trusts the winner param' do
          current_game.finish_game! winner: 'red'
          expect(current_game.winner).to eq('red')
        end
      end

      context 'ammo' do
        before { current_game.finish_game! player_outcomes_attributes: player_outcomes_hashes }
        it 'restores leftover ammo to the player' do
          expect(bob.reload.ammo).to eq(['balloon'])
        end
        it 'when no ammo is passed, assumes none is left over' do
          expect(rhoda.reload.ammo).to eq([])
        end
      end

      it 'nulls out path on all players' do
        current_game.finish_game!
        expect(bob.piece.reload.path).to be_nil
        expect(rhoda.piece.reload.path).to be_nil
      end

      it 'awards prizes' do
        expect(current_game).to receive(:award_prizes!)
        current_game.finish_game!
      end

      it 'awards mvp prizes' do
        expect(current_game).to receive(:award_mvp_prizes!)
        current_game.finish_game!
      end

    end
  end


  describe 'calculating post-game stats' do

    let!(:betty) { create_player team: 'blue', player_name: 'betty' }
    let!(:bob) { create_player team: 'blue', player_name: 'bob' }
    let!(:roger) { create_player team: 'red', player_name: 'roger' }
    let!(:rebecca) { create_player team: 'red', player_name: 'rebecca' }

    before do
      betty.set_piece(role: 'offense')
      bob.set_piece(role: 'defense')
      roger.set_piece(role: 'offense')
      rebecca.set_piece(role: 'defense')
    end

    let(:outcomes) {
      [
        # blue team won
        Outcome.new(team: 'blue', player_id: betty.id, captures: 1, takedowns: 1, flag_carry_distance: 10),
        Outcome.new(team: 'blue', player_id: bob.id, captures: 0, takedowns: 2, flag_carry_distance: 20),
        Outcome.new(team: 'red', player_id: roger.id, captures: 0, takedowns: 1, flag_carry_distance: 11),
        Outcome.new(team: 'red', player_id: rebecca.id, captures: 0, takedowns: 3, flag_carry_distance: 7),
      ]
    }

    let(:pieces) {
      [betty.piece, bob.piece, roger.piece, rebecca.piece]
    }

    let(:game) {
      Game.new(
        pieces: pieces,
        player_outcomes: outcomes
      )
    }

    let(:mvps) { game.mvps }

    it 'calculates winning team' do
      expect(game.calculate_winner).to eq('blue')
    end

    it 'calculates a draw as nil team' do
      outcomes.first.captures = 0
      expect(game.calculate_winner).to eq(nil)
    end

    before { game.lock_game! }

    describe 'MVPs' do
      before { game.finish_game! }

      it 'calculates attack_mvps for winning team (for winning team, this player captured the flag)' do
        expect(mvps['blue']['attack_mvps']).to eq([betty.id])
      end

      it 'calculates defend_mvps for winning team' do
        # this player had the most takedowns
        expect(mvps['blue']['defend_mvps']).to eq([bob.id])
      end

      it 'calculates attack_mvps for losing team' do
        # for losing team, this player held the flag for longest distance
        expect(mvps['red']['attack_mvps']).to eq([roger.id])
      end

      it 'calculates defend_mvps for losing team' do
        # this player had the most takedowns
        expect(mvps['red']['defend_mvps']).to eq([rebecca.id])
      end

      it "marks all MVPs in the player outcome record" do
        expect(game.outcome_for_player(betty).attack_mvp).to be true
        expect(game.outcome_for_player(betty).defend_mvp).to be false

        expect(game.outcome_for_player(bob).attack_mvp).to be false
        expect(game.outcome_for_player(bob).defend_mvp).to be true

        expect(game.outcome_for_player(roger).attack_mvp).to be true
        expect(game.outcome_for_player(roger).defend_mvp).to be false

        expect(game.outcome_for_player(rebecca).attack_mvp).to be false
        expect(game.outcome_for_player(rebecca).defend_mvp).to be true

      end

    end

    context 'when there are several potential mvps' do
      let(:billie) { create_player player_name: 'billie', team: 'blue', role: 'defense' }

      let(:outcomes) {
        [
          # blue team won
          Outcome.new(team: 'blue', player_id: betty.id, captures: 1, takedowns: 1, flag_carry_distance: 10),
          Outcome.new(team: 'blue', player_id: bob.id, captures: 0, takedowns: 2, flag_carry_distance: 20),
          Outcome.new(team: 'blue', player_id: billie.id, captures: 0, takedowns: 2, flag_carry_distance: 20),
          Outcome.new(team: 'red', player_id: roger.id, captures: 0, takedowns: 1, flag_carry_distance: 11),
          Outcome.new(team: 'red', player_id: rebecca.id, captures: 0, takedowns: 3, flag_carry_distance: 7),
        ]
      }

      before { game.finish_game! }

      it 'chooses a random one' do
        # expect(mvps['blue']['defend_mvps']).to eq([bob.id, billie.id])
        all_mvps = mvps['blue']['defend_mvps']
        expect(all_mvps.size).to eq(1)
        expect([bob.id, billie.id]).to include(all_mvps.first)
      end

      it 'remembers mvps on reload' do
        chosen_mvps = game.mvps
        game.save!
        20.times do
          reloaded_mvps = game.reload.mvps
          expect(reloaded_mvps).to eq(chosen_mvps)
        end
      end
    end

    context 'when there were no relevant events' do

      let(:outcomes) {
        [
          Outcome.new(team: 'blue', player_id: betty.id, captures: 0, takedowns: 0, flag_carry_distance: 0),
          Outcome.new(team: 'blue', player_id: bob.id, captures: 0, takedowns: 0, flag_carry_distance: 0),
          Outcome.new(team: 'red', player_id: roger.id, captures: 0, takedowns: 0, flag_carry_distance: 0),
          Outcome.new(team: 'red', player_id: rebecca.id, captures: 0, takedowns: 0, flag_carry_distance: 0),
        ]
      }
      before { game.finish_game! }

      it "doesn't set any MVP" do
        expect(mvps['blue']['attack_mvps']).to eq([])
        expect(mvps['blue']['defend_mvps']).to eq([])
        expect(mvps['red']['attack_mvps']).to eq([])
        expect(mvps['red']['defend_mvps']).to eq([])
      end

    end

    context "awarding prizes" do
      # temporarily make these private methodstestable
      before do
        class Game
          public :award_prizes!, :award_mvp_prizes!
        end
      end
      after do
        class Game
          private :award_prizes!, :award_mvp_prizes!
        end
      end

      it "every player on the winning team gets 1 gem" do
        game.award_prizes! winner: 'red'
        expect(betty.reload.gems).to eq(0)
        expect(bob.reload.gems).to eq(0)
        expect(roger.reload.gems).to eq(1)
        expect(rebecca.reload.gems).to eq(1)
      end

      it "when blue wins, every blue player gets 1 gem" do
        game.award_prizes! winner: 'blue'
        expect(betty.reload.gems).to eq(1)
        expect(bob.reload.gems).to eq(1)
        expect(roger.reload.gems).to eq(0)
        expect(rebecca.reload.gems).to eq(0)
      end

      it "tying teams, players get nothing" do
        game.award_prizes! winner: nil
        expect(betty.reload.gems).to eq(0)
        expect(bob.reload.gems).to eq(0)
        expect(roger.reload.gems).to eq(0)
        expect(rebecca.reload.gems).to eq(0)
      end

      it "all MVPs get one gem each" do
        # in this setup, every player is an mvp... should test more cases
        game.finish_game!

        expect(betty.reload.gems).to eq(2)
        expect(bob.reload.gems).to eq(2)
        expect(roger.reload.gems).to eq(1)
        expect(rebecca.reload.gems).to eq(1)
      end

    end

  end
end
