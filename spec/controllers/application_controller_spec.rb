require 'rails_helper'


describe ApplicationController, type: :controller do
  let!(:alice) { create_alice_with_piece }

  describe "login sessions" do
    let!(:new_session) { controller.send(:create_session, alice) }

    describe '#create_session' do

      it 'creates a session in the db' do
        expect(new_session).not_to be_new_record
        expect(new_session.player).to eq(alice)
      end

      # todo: store token, not id?
      it "stores the login session's id in the Rails session" do
        expect(session[ApplicationController::SESSION_KEY]).to eq(new_session.id)
      end

      it "assigns it as a controller ivar" do
        expect(assigns(:session)).to eq(new_session)
      end
    end

    describe '#find_player_from_session' do
      it 'finds the player' do
        p = controller.send(:find_player_from_session)
        expect(p).to eq(alice)
      end

      it 'or not' do
        session[ApplicationController::SESSION_KEY] = nil
        p = controller.send(:find_player_from_session)
        expect(p).to eq(nil)
      end

      it 'and no hacking' do
        session[ApplicationController::SESSION_KEY] = 'xyz'
        p = controller.send(:find_player_from_session)
        expect(p).to eq(nil)
      end

      it 'does not accept expired sessions' do
        session = new_session

        expire_session(session)

        p = controller.send(:find_player_from_session)
        expect(p).to eq(nil)

      end
    end

    describe '#current_player' do
      it 'finds the player based on session id' do
        session[ApplicationController::SESSION_KEY] = new_session.id
        p = controller.send(:current_player)
        expect(p).to eq(alice)
      end

      # it 'memoizes'
    end
  end
end
