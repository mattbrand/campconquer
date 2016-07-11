class GamesController < ApplicationController
  before_action :set_game,
                only: [:show,
                       :edit, :update, :destroy,
                       :lock, :unlock]

  skip_before_action :verify_authenticity_token # todo: put back in when we have auth?

  # GET /games
  # GET /games.json
  def index
    @games = Game.all.order(updated_at: :desc)
    render json: {status: 'ok', games: @games.as_json(include: [:pieces, :outcome])}
  end

  # GET /games/1
  # GET /games/1.json
  def show
    render_game
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    if @game.update(game_params_for_update)
      if @game.locked
        @game.locked = false # ???
        @game.save!
      end
      render :show, status: :ok, location: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy!
    render json: { status: 'ok', message: "game #{@game.id} deleted" }
  end

  # POST /games/1/lock
  def lock
    @game.update!(locked: true)
    render_game
  end

  # DELETE /games/1/lock
  def unlock
    @game.update!(locked: false)
    render_game
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params_for_update
    params.require(:game).permit(:winner)
  end

end
