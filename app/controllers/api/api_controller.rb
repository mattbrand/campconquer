module API
  class APIController < ApplicationController

    # homegrown auth, see SessionsController
    before_action :require_session_token, except: :maintenance_mode

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
      render_error status: :not_found,
                   message: "path '#{params[:path]}' not found"
    end

    def maintenance_mode
      render_error status: 503,
                   message: "down for maintenance"
    end


    protected

    # login and roles (see also ApplicationController)

    def good_session_token? token
      !!Player.for_session(token)
    end

    def current_session_token
      params[:token] || session[:token]
    end

    def current_player
      Player.for_session(current_session_token)
    end


    # errors

    def render_error (status: :internal_server_error, message:)
      render status: status,
             json: {
               status: "error",
               message: message,
             }
    end

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
