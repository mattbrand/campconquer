module API
  class APIController < ActionController::Base

    # homegrown auth, see SessionsController

    before_action :require_session_token

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :exception
    protect_from_forgery with: :null_session
    skip_before_filter :verify_authenticity_token

    # todo: explicit unit test for error handlers

    # stupid rescue_from ordering is *reversed* from regular rescue (matches bottom-to-top)
    rescue_from Exception, :with => :server_error
    rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid
    rescue_from ActiveRecord::RecordNotSaved, :with => :record_not_saved
    rescue_from ActionController::RoutingError, :with => :route_not_found

    public

    def route_not_found
      render :status => :not_found,
             :json => {
               'status' => 'error',
               'message' => "path '#{params[:path]}' not found"
             }
    end

    def good_session_token? token
      # todo: simulate session creation in tests instead of this gory backdoor
      if !token.nil? && token == SessionsController::GOOD_SESSION_TOKEN
        true
      else
        !!Player.for_session(token)
      end
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
        render status: :unauthorized, # in HTTP, "401 Unauthorized" means unauthenticated :-/
               json: {
                 status: "error",
                 message: "This is a protected endpoint and you are unauthenticated - please pass in a good token",
               }
      elsif !good_session_token? token
        render status: :unauthorized, # in HTTP, "401 unauthorized" means unauthenticated :-/
               json: {
                 status: "error",
                 message: "This is a protected endpoint and your token is invalid",
               }
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

    protected

    # errors

    def record_not_found(e)
      render :status => :not_found,
             :json => exception_as_json(e)
    end

    def record_not_saved(e)
      message = if e.record
                  e.record.errors.full_messages.join("\n")
                else
                  "record not saved: #{e.message}"
                end

      render status: :unprocessable_entity,
             json: exception_as_json(e) + {
               message: message
             }
    end

    # warning: only works for RecordInvalid exceptions
    def record_invalid(e)
      record = e.record
      render status: :unprocessable_entity,
             json: exception_as_json(e) + {
               message: record.errors.full_messages.join("\n"),
               errors: record.errors,
             }
    end

    def server_error(e)
      render :status => :internal_server_error,
             :json => exception_as_json(e)
    end

    def forbidden(why)
      render status: :forbidden, # in HTTP, "403 Forbidden" means unauthorized :-/
             json: {
               status: "error",
               message: "This is a protected endpoint and you are unauthorized (#{why})",
             }
    end

    def exception_as_json(e)
      {
        'status' => 'error',
        'message' => e.message, # suitable for display to user, more or less
        'exception' => exception_as_hash(e)
      }
    end

    def exception_as_hash(e)
      hash = {
        'class' => e.class.name,
        'message' => e.message,
        'trace' => e.backtrace # todo: turn this off in production? or is security through obscurity an illusion?
      }
      if e.cause
        hash['cause'] = exception_as_hash(e.cause)
      end
      hash
    end

    # finding

    def find_game
      game_id = params[:game_id] || params[:id]
      if game_id == 'current'
        @game = Game.current || raise(ActiveRecord::RecordNotFound, "current game not found")
      elsif game_id == 'previous'
        @game = Game.previous || raise(ActiveRecord::RecordNotFound, "previous game not found")
      else
        @game = Game.find(game_id)
      end
    end

    def find_player
      player_id = params[:player_id] || params[:id]
      @player = Player.find(player_id)
    end

    def pull_activity
      if @player and @player.authenticated?
        @player.pull_recent_activity!
      end
    end

    def find_season
      season_id = params[:season_id] || params[:id]
      if season_id == 'current'
        @season = Season.current || raise(ActiveRecord::RecordNotFound, "current season not found")
      elsif season_id == 'previous'
        @season = Season.previous || raise(ActiveRecord::RecordNotFound, "previous season not found")
      else
        @season = Season.find(season_id)
      end
    end

    # rendering

    def render_game(**args)
      game_hash = @game.as_json
      game_hash['moves'] = @game.moves.as_json if params[:include_moves].to_boolean

      body = {status: 'ok', game: game_hash}
      render json: body, **args
    end

    def render_ok(response, render_args: {})
      body = {status: 'ok'} + response
      render json: body, **render_args
    end

    def render_player(**args)
      body = {status: 'ok', player: @player.as_json}
      render json: body, **args
    end

    def render_season(**args)
      body = {status: 'ok', season: @season.as_json}
      render json: body, **args
    end

  end
end
