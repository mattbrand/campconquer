require 'rails_helper'

describe API::SessionsController, type: :controller do

  let(:good_password) { 'mydoghasfleas' }
  let(:bad_password) { 'bogus' }
  let!(:alice) { create_player(player_name: 'alice', password: good_password) }

  context 'given a valid username and password' do
    it 'returns a player id' do
      get :create, name: 'alice', password: good_password
      expect_ok
      expect(response_json['player_id']).to eq(alice.id)
    end

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
      expect(controller.send(:good_session_token?, token)).to eq(true)
      expect(controller.send(:good_session_token?, "NOT A GOOD TOKEN")).to eq(false)
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

  context 'given a user with no password' do
    it 'fails to start a session' do
      alice.update(password: nil)
      get :create, name: 'alice', password: nil
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
      expect(subject.send(:current_player)).to eq(alice)
    end
  end

  context 'given a valid username and password for a CONTROL GROUP user' do
    it 'fails to start a session' do
      charlie = Player.create!(name: 'charlie', password: good_password, team: 'control')

      get :create, name: 'charlie', password: good_password
      expect(response.body).to include('"status":"error"')
      expect(response_json).to include({"status" => "error"})
      expect(response_json["message"].downcase).to include("control group players cannot play the game")
      expect(response.status).to eq(403)
    end
  end

end
