module API
  class GamesController < APIController
    before_action :find_game, only: [:show,
                                     :update,
                                     :destroy,
                                     :lock,
                                     :unlock]

    before_action ->{ require_role(:gamemaster) }, except: [:index, :show]

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
      if !@game.in_progress?
        render status: :conflict,
               json: {
                 status: 'error',
                 message: 'You can only set an outcome on a locked (in progress) game'
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
      params.require(:game).permit(:winner,
                                   :match_length,
                                   :moves,
                                   player_outcomes: [
                                     :team_name,
                                     :player_id,
                                     :takedowns,
                                     :throws,
                                     :pickups,
                                     :captures,
                                     :flag_carry_distance,
                                     {ammo: []}
                                   ],

      )
    end

  end
end
