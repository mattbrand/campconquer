class TeamOutcomesController < ApplicationController
  before_action :set_team_outcome, only: [:show, :edit, :update, :destroy]

  # GET /team_outcomes
  # GET /team_outcomes.json
  def index
    @team_outcomes = TeamOutcome.all
  end

  # GET /team_outcomes/1
  # GET /team_outcomes/1.json
  def show
  end

  # GET /team_outcomes/new
  def new
    @team_outcome = TeamOutcome.new
  end

  # GET /team_outcomes/1/edit
  def edit
  end

  # POST /team_outcomes
  # POST /team_outcomes.json
  def create
    @team_outcome = TeamOutcome.new(team_outcome_params)

    respond_to do |format|
      if @team_outcome.save
        format.html { redirect_to @team_outcome, notice: 'Team outcome was successfully created.' }
        format.json { render :show, status: :created, location: @team_outcome }
      else
        format.html { render :new }
        format.json { render json: @team_outcome.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_outcomes/1
  # PATCH/PUT /team_outcomes/1.json
  def update
    respond_to do |format|
      if @team_outcome.update(team_outcome_params)
        format.html { redirect_to @team_outcome, notice: 'Team outcome was successfully updated.' }
        format.json { render :show, status: :ok, location: @team_outcome }
      else
        format.html { render :edit }
        format.json { render json: @team_outcome.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_outcomes/1
  # DELETE /team_outcomes/1.json
  def destroy
    @team_outcome.destroy
    respond_to do |format|
      format.html { redirect_to team_outcomes_url, notice: 'Team outcome was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team_outcome
      @team_outcome = TeamOutcome.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_outcome_params
      params.require(:team_outcome).permit(:team, :deaths, :takedowns, :throws, :captures)
    end
end
