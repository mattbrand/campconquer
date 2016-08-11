class OutcomesController < ApplicationController
  before_action :set_game
  before_action :set_outcome, only: [:show, :edit, :update, :destroy]

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
    params[:team_outcomes_attributes] = params.delete(:team_outcomes) if params[:team_outcomes]

    @game.finish_game!(params)

    render status: :created,
           json: {status: 'ok'}
  end

  private

  def set_outcome
    @outcome = Outcome.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def outcome_params
    params.require(:outcome).permit(:winner,
                                    :match_length,
                                    :moves,
                                    team_outcomes: [
                                      :team, :takedowns, :throws, :pickups
                                    ])
  end


end
