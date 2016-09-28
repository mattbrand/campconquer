require 'rails_helper'

describe AmmosController, type: :controller do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GamesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    request.accept = "application/json"
  end

  describe "GET /ammos" do
    it "returns all ammos as json" do
      get :index, {}, valid_session

      expect(response_json).to include({'status' => 'ok'})
      expect(response_json).to include('ammos')

      some_ammo = Ammo.all.first.as_json
      expect(response_json['ammos']).to include(some_ammo.deep_stringify_keys)
    end

  end
end
