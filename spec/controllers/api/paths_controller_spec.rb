require 'rails_helper'

describe API::PathsController, type: :controller do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GamesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    request.accept = "application/json"
  end

  describe "GET /paths" do
    it "returns all paths as json" do
      get :index, {}, valid_session

      expect(response_json).to include({'status' => 'ok'})
      expect(response_json).to include('paths')

      # this happens to be the first row of hardcoded paths.csv;
      # may need to change some day after a re-export
      some_path = {
        team: 'blue',
        role: 'defense',
        points: [
          {x: 12.0, y: 2.5}
        ]
      }
      expect(response_json['paths']).to include(some_path.deep_stringify_keys)
    end

  end
end
