require 'rails_helper'

describe API::SessionsController, type: :controller do

  let(:good_password) { 'mydoghasfleas' }
  let(:bad_password) { 'bogus' }
  let!(:alice) { create_player(player_name: 'alice', password: good_password) }

  context 'given a valid username and password' do

    it 'returns a session token' do
      get :create, name: 'alice', password: good_password
      expect_ok
      token = response_json['token']
      expect(token).to be
      expect(alice.reload.session_token).to eq(token)
    end

    it 'returns a session token that can be used to get past the session check' do
      get :create, name: 'alice', password: 'password'
      token = response_json['token']
      expect(controller.good_session_token?(token)).to eq(true)
      expect(controller.good_session_token?("NOT A GOOD TOKEN")).to eq(false)
    end
  end

  context 'given a valid username and bogus password' do
    it 'fails to start a session' do
      get :create, name: 'alice', password: bad_password
      expect(response.body).to include('"status":"error"')
      expect(response_json).to include({"status" => "error"})
      expect(response_json["message"].downcase).to include("bad")
      expect(response.status).to eq(401)
    end
  end

  context 'given a valid user id and password' do

    before do
      get :create, name: alice.id, password: good_password
      expect_ok
    end

    it 'returns a session token' do
      token = response_json['token']
      expect(token).to be
      expect(alice.reload.session_token).to eq(token)
    end

    it 'sets a session token' do
      token = session[:token]
      expect(token).to be
      expect(alice.reload.session_token).to eq(token)
    end

    it 'fetches a current player (user?)' do
      expect(subject.current_player).to eq(alice)
    end
  end
end
