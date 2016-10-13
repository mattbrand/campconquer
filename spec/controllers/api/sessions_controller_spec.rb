require 'rails_helper'

describe API::SessionsController, type: :controller do

  context 'given a valid username and password' do
    before do
      Player.create! name: 'alice', team: 'red'
    end

    it 'returns a session token' do
      get :create, name: 'alice', password: 'password'
      expect_ok
      token = response_json['token']
      expect(token).to be
    end

    it 'returns a session token that can be used to get past the session check' do
      expect(controller.good_session_token?("NOT A GOOD TOKEN")).to eq(false)
      get :create, name: 'alice', password: 'password'
      token = response_json['token']
      expect(controller.good_session_token?(token)).to eq(true)
    end
  end

end
