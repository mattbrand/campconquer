class ApplicationController < ActionController::Base

protected

  # login and roles

  def good_session_token? token
    !!Player.for_session(token)
  end

  def current_session_token
    params[:token] || session[:token]
  end

  def current_player
    Player.for_session(current_session_token)
  end

  def require_session_token
    token = current_session_token

    # see https://www.loggly.com/blog/http-status-code-diagram/
    if token.nil?
      render_error status: :unauthorized, # in HTTP, "401 Unauthorized" means unauthenticated :-/
                   message: "This is a protected endpoint and you are unauthenticated - please pass in a good token"
    elsif !good_session_token? token
      render_error status: :unauthorized, # in HTTP, "401 unauthorized" means unauthenticated :-/
                   message: "This is a protected endpoint and your token is invalid"
    end
  end

  def require_role(required_role)
    unless current_player.send("#{required_role}?")
      forbidden("role '#{required_role}' required")
    end
  end

  def require_player(required_player)
    if current_player != required_player and !current_player.admin?
      forbidden("player #{required_player.name.inspect} or admin required")
    end
  end

  def forbidden(why)
    render_error status: :forbidden, # in HTTP, "403 Forbidden" means unauthorized :-/
                 message: "This is a protected endpoint and you are unauthorized (#{why})"
  end

end
