require 'rails_helper'

RSpec.describe "TeamOutcomes", type: :request do
  describe "GET /team_outcomes" do
    it "works! (now write some real specs)" do
      get team_outcomes_path
      expect(response).to have_http_status(200)
    end
  end
end
