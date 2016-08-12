module ControllerHelpers
  def response_json
    @response_json ||= JSON.parse(response.body)
  rescue
    raise RSpec::Expectations::ExpectationNotMetError.new "expected JSON but received #{response.body.inspect}"
  end

  def expect_ok
    expect(response.body).to eq({status: 'ok'}.to_json)
    expect(response.status).to be_in([200, 201, 202])
  end

end
