module API
  class SessionsController < APIController
    # todo: simulate session creation in tests instead of this gory backdoor
    GOOD_SESSION_TOKEN = Rails.env.test? ? "GOOD-#{SecureRandom.hex(10)}" : nil

    skip_before_action :check_session

    def create
      player = Player.find_by_name(params[:name]) || Player.find(params[:name])
      if player && player.has_password?(params[:password])
        token = player.start_session
        render_ok(token: token)
      else
        render status: :unauthorized, # in HTTP, "401 Unauthorized" means unauthenticated :-/
               json: {
                 status: "error",
                 message: "bad username/password",
               }
      end
    end
  end
end
