require 'rails_helper'

module API
  describe APIController, type: :controller do

    let(:alice) {
      Player.create! name: 'alice', team: 'red'
    }

    context 'given no token' do
      it 'allows "create session"' do
        @controller = SessionsController.new
        get :create
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
        get :create, token: 'BOGUS'
        expect_ok
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
        good_token = SessionsController::GOOD_SESSION_TOKEN
        @controller = PlayersController.new
        get :show, {id: alice.id}, valid_session
        expect_ok
      end

    end

    context 'given a valid token as a param' do

      it "allows most calls" do
        good_token = SessionsController::GOOD_SESSION_TOKEN
        @controller = PlayersController.new
        get :show, id: alice.id, token: good_token
        expect_ok
      end

      it "allows players to change their own stuff"

      it "disallows players to change other players' stuff"
      # expect(response.status).to eq(403) # in HTTP, "403 Forbidden" means unauthorized

      it "allows admins to change anyone's own stuff"
    end

  end
end
