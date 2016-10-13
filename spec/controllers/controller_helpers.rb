module ControllerHelpers
  def response_json
    @response_json ||= JSON.parse(response.body)
  rescue
    raise RSpec::Expectations::ExpectationNotMetError.new "expected JSON but received #{response.body.inspect}"
  end

  def expect_ok
    expect(response.body).to include('"status":"ok"')
    expect(response_json).to include({"status" => "ok"})
    expect(response.status).to be_in([200, 201, 202])
  rescue RSpec::Expectations::ExpectationNotMetError => e
    ap response_json
    raise e
  end

  def valid_session
    {token: API::SessionsController::GOOD_SESSION_TOKEN}
  end

end
