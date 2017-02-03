# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default(FALSE), not null
#  start_at   :date
#

require 'rails_helper'

RSpec.describe "Seasons", type: :request do
  describe "GET /seasons" do
    it "works but fails to authorize a non-gamemaster" do
      get seasons_path
      expect(response).to have_http_status(403)
    end
  end
end
