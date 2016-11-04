class SessionsController < WebController

  def new
    @session = Session.new
  end

  def create
    username = params[:session][:name]
    player = Player.find_by_name(username)
    if player
      password = params[:session][:password]
      if player.has_password?(password)
        # self.current_player = player

        create_session(player)

        flash.notice = "Signed in as #{player.name}"
        redirect_to '/'
        return
      end
    end
    @session = Session.new(name: username)
    flash.alert = "Bad username/password"
    render action: :new
  end

  def destroy
    destroy_session
    redirect_to '/'
  end

  protected

end
