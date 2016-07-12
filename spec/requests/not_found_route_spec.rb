require 'rails_helper'
describe 'making a request to an unrecognised path' do
# before { host! 'api.example.com' }
  it 'returns 404' do
    get '/nowhere'
    expect(response.status).to eq(404)
    expect(JSON.parse(response.body)).to include(
                                           {'message' =>
                                              "path 'nowhere' not found"
                                           }
                                         )
  end
end
