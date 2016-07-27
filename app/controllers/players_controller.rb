class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy, :auth]

  # GET /players
  def index
    @players = Player.all
    render json: {
      status: 'ok',
      players: @players.as_json,
    }
  end

  # GET /players/1
  def show
    render json: {
      status: 'ok',
      player: @player.as_json,
    }
  end

  # POST /players
  def create
    @player = Player.create!(player_params)
    @player.save!
    render :json => {
      status: 'ok',
      player: @player.as_json,
    }
  end

  # PATCH/PUT /players/1
  def update
    @player.update!(player_params)
    render :json => {
      status: 'ok',
      player: @player.as_json,
    }
  end

  def auth
    redirect_to @player.begin_auth # todo: test
  end

  def auth_callback
    player = Player.find_by_anti_forgery_token(params[:state])
    player.finish_auth(params[:code]) # todo: test
    redirect_to profile_player_path(player)
  end

  # just for demo
  def profile
    set_player
    puts "fetching user profile"
    user_profile = @player.fitbit.get_user_profile
    render json: user_profile
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def player_params
    params.require(:player).permit(:name, :team)
  end
end
