module ControllerHelpers
  def response_json
    @response_json ||= JSON.parse(response.body)
  rescue
    raise RSpec::Expectations::ExpectationNotMetError.new "expected JSON but received #{response.body.inspect}"
  end
end
