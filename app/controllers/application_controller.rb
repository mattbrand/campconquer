class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def set_game
    game_id = params[:game_id] || params[:id]
    if game_id == 'current'
      @game = Game.current
    else
      @game = Game.find(game_id)
    end
  end

  def render_game(**args)
    body = {status: 'ok'}.merge(@game.as_json(root: true, include: [:pieces, :outcome]))
    render args.merge(json: body)
  end

end
