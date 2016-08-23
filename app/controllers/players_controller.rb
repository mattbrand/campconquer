class PlayersController < ApplicationController
  before_action :find_player, only: [:show,
                                     :edit,
                                     :update,
                                     :destroy,
                                     :auth,
                                     :redeem,
                                     :profile,
                                     :steps,
                                     :activities]

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
    render_player
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
    # redirect_to profile_player_path(player)
    redirect_to admin_players_path
  end

  def redeem
    @player.redeem_steps!
    render_player
  end

  def buy
    raise "Not implemented"
  end

  # just for demo
  def steps
    puts "fetching user activities"
    # output['activity-types'] = @player.fitbit.get('/1/activities.json') # the whole list -- big
    output = {}
    a_while_ago = (Time.current - 3.month).strftime('%F')
    yesterday = (Time.current - 1.day).strftime('%F')
    output = @player.fitbit.get("/1/user/-/activities/steps/date/#{a_while_ago}/#{yesterday}.json")
    render json: output
  end

  # just for demo
  def activities
    puts "fetching user activities"
    # output['activity-types'] = @player.fitbit.get('/1/activities.json') # the whole list -- big
    render json: @player.fitbit.get_activities(Date.today.strftime('%F'))
  end

  # just for demo
  def profile
    puts "fetching user profile"
    render json: @player.fitbit_profile
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def find_player
    @player = Player.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def player_params
    params.require(:player).permit(:name, :team)
  end
end
