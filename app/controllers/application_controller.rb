class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  # login and roles

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

  # for web login
  # (I wanted these to go in WebController but I don't see a way to make ActiveAdmin
  # extend WebController instead of ApplicationController)

  SESSION_KEY = :current_player_session_id

  def find_player_from_session
    if session[SESSION_KEY]
      session_object = Session.where(id: session[SESSION_KEY]).includes(:player).first
      if session_object
        session_object.player
      end
    end
  end

  def create_session(player)
    @session = Session.create!(player_id: player.id)
    destroy_session
    session[SESSION_KEY] = @session.id
    @session
  end

  def destroy_session
    if session[SESSION_KEY]
      Session.destroy(session[SESSION_KEY])
      session[SESSION_KEY] = nil
    end
  end

  def current_player
    @current_player ||= find_player_from_session
  end
  helper_method :current_player

  # for active_admin
  def authenticate_admin_user!
    unless current_player && current_player.admin?
      flash[:alert] = "Only admins can access that page."
      redirect_to login_path
    end
  end

end
