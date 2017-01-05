require 'rails_helper'

module API
  describe APIController, type: :controller do

    let(:alice) { create_player player_name: 'alice', team: 'red' }
    before { start_session(alice) }

    context 'given no token' do
      it 'allows "create session"' do
        @controller = SessionsController.new
        get :create, name: alice.name, password: 'password'
        expect_ok
      end

      it 'denies most other calls' do
        @controller = PlayersController.new
        get :show, id: alice.id
        expect(response.body).to include('"status":"error"')
        expect(response_json).to include({"status" => "error"})
        expect(response_json["message"].downcase).to include("unauthenticated")
        expect(response.status).to eq(401)
      end
    end

    context 'given an invalid token' do

      it 'allows "create session"' do
        @controller = SessionsController.new
        get :create, token: 'BOGUS', name: alice.name, password: 'password'
        expect_ok
        expect(response_json["token"]).not_to eq('BOGUS')
      end

      it 'denies most other calls' do
        @controller = PlayersController.new
        get :show, id: alice.id, token: 'BOGUS'
        expect(response.body).to include('"status":"error"')
        expect(response_json).to include({"status" => "error"})
        expect(response_json["message"].downcase).to include("invalid")
        expect(response.status).to eq(401) # in HTTP, "401 Unauthorized" means unauthenticated :-/
      end
    end

    # todo: unify the two valid token cases (param and session)
    #    RSpec.shared_context "valid token" do ...

    context 'given a valid token in the session' do
      it "allows most calls" do
        start_session(alice)
        @controller = PlayersController.new
        get :show, {id: alice.id}, valid_session
        expect_ok
      end

    end

    context 'given a valid token as a param' do
      it "allows most GET calls" do
        start_session(alice)
        @controller = PlayersController.new
        get :show, id: alice.id, token: @session_token
        expect_ok
      end
    end

    context 'roles' do
      let!(:alice) { create_alice_with_piece }
      let!(:bob) { create_bob_with_piece }

      let!(:galoshes) do
        g = Gear.new(name: 'galoshes', gear_type: 'shoes', coins: 1, gems: 0)
        Gear.all = [g]
        g
      end

      after do
        Gear.reset
      end

      context 'a player' do
        before { @controller = PlayersController.new }
        let!(:token) { alice.start_session }

        it "can see their own stuff" do
          get :show, id: alice.id, token: token
          expect_ok
        end

        it "can see others' stuff" do
          get :show, id: bob.id, token: token
          expect_ok
        end

        it "can change their own stuff" do
          post :buy, id: alice.id, token: token, gear: {name: 'galoshes'}
          expect_ok
          expect(alice.reload.gear_owned).to include('galoshes')
        end

        it "can't change others' stuff" do
          post :buy, id: bob.id, token: token, gear: {name: 'galoshes'}
          expect(response.status).to eq(403) # in HTTP, "403 Forbidden" means unauthorized
          expect(bob.reload.gear_owned).not_to include('galoshes')
        end
      end

      context 'an admin' do
        before { @controller = PlayersController.new }
        before { alice.update(admin: true) }
        let!(:token) { alice.start_session }

        it "can see their own stuff" do
          get :show, id: alice.id, token: token
          expect_ok
        end

        it "can see others' stuff" do
          get :show, id: bob.id, token: token
          expect_ok
        end

        it "can change their own stuff" do
          post :buy, id: alice.id, token: token, gear: {name: 'galoshes'}
          expect_ok
          expect(alice.reload.gear_owned).to include('galoshes')
        end

        it "can't change others' stuff" do
          post :buy, id: bob.id, token: token, gear: {name: 'galoshes'}
          expect_ok
          expect(bob.reload.gear_owned).to include('galoshes')
        end
      end

      context 'game locking -- ' do
        before { @controller = GamesController.new }
        let(:gertie) { create_gamemaster }

        it "a gamemaster can lock a game" do
          token = gertie.start_session
          post :lock, id: Game.current.id, token: token
          expect_ok
          expect(Game.current).to be_locked
        end

        it "a normal player can't lock a game" do
          token = bob.start_session
          post :lock, id: Game.current.id, token: token
          expect(response.status).to eq(403) # in HTTP, "403 Forbidden" means unauthorized
          expect(Game.current).not_to be_locked
        end
      end

    end
  end
end
