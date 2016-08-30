class OutcomesController < ApplicationController
  before_action :find_game
  before_action :find_outcome, only: [:show, :edit, :update, :destroy]

  # POST /outcomes
  def create
    if !@game.locked?
      render status: :conflict,
             json: {
               status: 'error',
               message: 'You can only set an outcome on a locked game'
             }
      return
    end

    params = outcome_params
    params[:player_outcomes_attributes] = params.delete(:player_outcomes) if params[:player_outcomes]

    @outcome = @game.finish_game!(params)

    render status: :created,
           json: {status: 'ok'}
  end

  private

  def find_outcome
    @outcome = Outcome.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def outcome_params
    params.require(:outcome).permit(:winner,
                                    :match_length,
                                    :moves,
                                    player_outcomes: [
                                      :team,
                                      :player_id,
                                      :takedowns,
                                      :throws,
                                      :pickups,
                                      :captures,
                                      :attack_mvp,
                                      :defend_mvp,
                                    ],

    )
  end


end
