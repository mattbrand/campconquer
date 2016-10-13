module API
  class SessionsController < APIController
    GOOD_SESSION_TOKEN = 'GOOD'

    skip_before_action :check_session

    def create
      render_ok(token: GOOD_SESSION_TOKEN)
    end
  end
end
