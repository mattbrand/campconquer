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
  rescue_from ActionController::RoutingError, :with => :route_not_found


  public
  def route_not_found
    render :status => :not_found,
           :json => {
             'status' => 'error',
             'message' => "path '#{params[:path]}' not found"
           }
  end

  protected

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

    unless Rails.env.test?
      # TODO: move this into a background task!!!
      @player.pull_activity! Date.current - 1.day
      @player.pull_activity! Date.current
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
    body = {status: 'ok', game: @game.as_json}
    render json: body, **args
  end

  def render_player(**args)
    body = {status: 'ok', player: @player.as_json}
    render json: body, **args
  end

end
