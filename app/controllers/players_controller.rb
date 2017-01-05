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

  # GET /players/1
  def show
    pull_activity if @player.activities_synced_at.nil? or @player.activities_synced_at < 10.minutes.ago
  end

end
