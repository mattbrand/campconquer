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

    puts "HI! MOVES="
    ap params[:moves]

    params = outcome_params
    params[:team_outcomes_attributes] = params.delete(:team_outcomes) if params[:team_outcomes]

    @outcome = Outcome.new(params)

    replace_outcome(@game, @outcome)
    @game.update!(current: false, locked: false)
    @game.unlock_game!

    render status: :created,
           json: {status: 'ok'}
  end

  private

  def set_outcome
    @outcome = Outcome.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def outcome_params
    params.require(:outcome).permit(:winner, :match_length,
                                    team_outcomes: [
                                      :team, :takedowns, :throws, :pickups
                                    ])
  end

  # should this be inside the model?
  def replace_outcome(game, outcome)
    outcome.validate! # force a RecordInvalid exception on the outcome before saving the game
    # should these be in a transaction?
    old_outcome = game.outcome
    game.outcome = outcome # this saves it too
    old_outcome.destroy! if old_outcome
  end


end
