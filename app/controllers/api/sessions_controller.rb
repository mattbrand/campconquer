module API
  class SessionsController < APIController
    skip_before_action :require_session_token

    def create
      player = Player.find_by_name(params[:name]) || Player.find_by_id(params[:name])
      if player && !params[:password].blank? && player.has_password?(params[:password])
        if player.in_control_group?
          forbidden("control group players cannot play the game")
        else
          session[:token] = player.start_session
          render_ok(token: session[:token], player_id: player.id)
        end

      else
        render status: :unauthorized, # in HTTP, "401 Unauthorized" means unauthenticated :-/
               json: {
                   status: "error",
                   message: "bad username/password",
               }
      end
    end

    def new
      create
    end
  end
end
