require 'rails_helper'

describe API::AmmosController, type: :controller do

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
