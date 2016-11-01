module API
  class SessionsController < APIController
    # todo: simulate session creation in tests instead of this gory backdoor
    GOOD_SESSION_TOKEN = Rails.env.test? ? "GOOD-#{SecureRandom.hex(10)}" : nil

    skip_before_action :require_session_token

    def create
      player = Player.find_by_name(params[:name]) || Player.find(params[:name])
      if player && player.has_password?(params[:password])
        session[:token] = player.start_session
        render_ok(token: session[:token], player_id: player.id)
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
