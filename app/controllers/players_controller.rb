class PlayersController < WebController
  before_action -> { require_role('admin') }, only: [:auth, :auth_callback]
  before_action :find_player, except: [:auth_callback]

  def auth
    redirect_to @player.begin_auth
  end

  # note: this does not require login auth since it's called via redirect from fitbit.com
  def auth_callback
    token = params[:state]
    player = Player.find_by_anti_forgery_token(token)
    if player
      player.finish_auth(params[:code]) # todo: test
      redirect_to admin_players_path
    else
      render_error message: "Couldn't find player with fitbit anti_forgery_token #{token.inspect}"
    end
  end

  # # just for demo
  # def steps
  #   puts "fetching user activities"
  #   # output['activity-types'] = @player.fitbit.get('/1/activities.json') # the whole list -- big
  #   output = {}
  #   a_while_ago = (Time.current - 3.month).strftime('%F')
  #   yesterday = (Time.current - 1.day).strftime('%F')
  #   output = @player.fitbit.get("/1/user/-/activities/steps/date/#{a_while_ago}/#{yesterday}.json")
  #   render json: output
  # end
  #
  # # just for demo
  # def activities
  #   puts "fetching user activities"
  #   # output['activity-types'] = @player.fitbit.get('/1/activities.json') # the whole list -- big
  #   render json: @player.fitbit.get_activities(Date.today.strftime('%F'))
  # end
  #
  # # just for demo
  # def profile
  #   puts "fetching user profile"
  #   render json: @player.fitbit_profile
  # end

end
