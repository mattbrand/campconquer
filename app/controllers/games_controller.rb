class GamesController < ApplicationController
  before_action :find_game, only: [:show,
                                   :edit,
                                   :update,
                                   :destroy,
                                   :lock,
                                   :unlock]

  skip_before_action :verify_authenticity_token # todo: put back in when we have auth?

  # GET /games
  def index
    @games = Game.all.order(updated_at: :desc)
    render json: {status: 'ok',
                  games: @games.as_json(Game.serialization_options)}
  end

  # GET /games/1
  def show
    render_game
  end

  # DELETE /games/1
  def destroy
    @game.destroy!
    render json: {status: 'ok', message: "game #{@game.id} deleted"}
  end

  # POST /games/1
  def update
    if !@game.locked?
      render status: :conflict,
             json: {
               status: 'error',
               message: 'You can only set an outcome on a locked game'
             }
      return
    end

    params = game_params
    params[:player_outcomes_attributes] = params.delete(:player_outcomes) if params[:player_outcomes] # rails is weird

    @outcome = @game.finish_game!(params)

    render_game status: :created
  end

  # POST /games/1/lock
  def lock
    @game.lock_game!

    render_game # todo: message: "game locked"
  end

  # DELETE /games/1/lock
  def unlock
    @game.unlock_game!
    render json: {status: 'ok', message: "game #{@game.id} unlocked"}
  end

  private

  def game_params
    params.permit(:winner,
                  :match_length,
                  :moves,
                  player_outcomes: [
                    :team,
                    :player_id,
                    :takedowns,
                    :throws,
                    :pickups,
                    :captures,
                    :flag_carry_distance,
                    :attack_mvp,
                    :defend_mvp,
                  ],

    )
  end

end
