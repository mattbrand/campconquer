class OutcomesController < ApplicationController
  before_action :set_game
  before_action :set_outcome, only: [:show, :edit, :update, :destroy]

  # POST /outcomes
  # POST /outcomes.json
  def create
    params = outcome_params
    params[:team_outcomes_attributes] = params.delete(:team_outcomes) if params[:team_outcomes]
    ap params
    @outcome = Outcome.new(params)
    begin
      old_outcome = @game.outcome
      @game.outcome = @outcome
      old_outcome.destroy! if old_outcome
      render json: {status: 'ok'}, status: :created
    rescue ActiveRecord::RecordNotSaved => e
      render json: {status: 'error', errors: @outcome.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_outcome
    @outcome = Outcome.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def outcome_params
    params.require(:outcome).permit(:winner, :team_stats_id, :match_length,
                                    team_outcomes: [
                                      :team, :takedowns, :throws, :pickups
                                    ])
  end


end
