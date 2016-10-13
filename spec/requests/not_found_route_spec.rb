require 'rails_helper'
describe 'making a request to an unrecognised path' do
# before { host! 'api.example.com' }

  context 'api' do
    include ControllerHelpers
    it 'returns 404 and json' do
      get '/api/nowhere', valid_session
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to include(
                                             {'message' =>
                                                "path 'nowhere' not found"
                                             }
                                           )
    end
  end
  context 'web' do
    it 'returns 404 and HTML' do
      get '/nowhere'
      expect(response.status).to eq(404)
      expect(response.body).to include("<html")
      expect(response.body).to include("not found")
    end
  end
end
