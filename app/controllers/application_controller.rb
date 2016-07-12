class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # todo: explicit unit test for error handlers

  # stupid rescue_from ordering is *reversed* from regular rescue (matches bottom-to-top)
  rescue_from Exception, :with => :server_error
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid
  rescue_from ActiveRecord::RecordNotSaved, :with => :record_not_saved

  protected

  def record_not_found(e)
    render :status => :not_found,
           :json => exception_as_json(e)
  end

  def record_not_saved(e)
    render status: :unprocessable_entity,
           json: exception_as_json(e) + {
             message: e.record.errors.full_messages.join("\n")
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

  def set_game
    game_id = params[:game_id] || params[:id]
    if game_id == 'current'
      @game = Game.current
    else
      @game = Game.find(game_id)
    end
  end

  def exception_as_json(e)
    {
      :status => 'error',
      :message => e.message, # suitable for display to user, more or less
      :exception => {
        :class => e.class.name,
        :message => e.message,
        :trace => e.backtrace # todo: turn this off in production? or is security through obscurity an illusion?
      }
    }
  end

  def render_game(**args)
    body = {status: 'ok'}.merge(@game.as_json)
    render args.merge(json: body)
  end

  def set_player
    player_id = params[:player_id] || params[:id]
    if player_id == 'current'
      @player = Player.current
    else
      @player = Player.find(player_id)
    end
  end


end
