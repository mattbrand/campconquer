class GamesController < ApplicationController
  before_action :set_game,
                only: [:show,
                       :edit, :update, :destroy,
                       :lock, :unlock]

  skip_before_action :verify_authenticity_token # todo: put back in when we have auth?

  # GET /games
  def index
    @games = Game.all.order(updated_at: :desc)
    render json: {status: 'ok', games: @games.as_json(include: [:pieces, :outcome])}
  end

  # GET /games/1
  def show
    render_game
  end

  # DELETE /games/1
  def destroy
    @game.destroy!
    render json: { status: 'ok', message: "game #{@game.id} deleted" }
  end

  # POST /games/1/lock
  def lock
    @game.lock_game!

    render_game # todo: message: "game locked"
  end

  # DELETE /games/1/lock
  def unlock
    @game.unlock_game!
    @game.pieces.destroy_all
    render json: { status: 'ok', message: "game #{@game.id} unlocked" }
  end

end
