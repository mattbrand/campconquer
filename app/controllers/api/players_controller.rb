class API::PlayersController < ::API::APIController

  before_action :find_player, except: [:index]

  before_action -> { require_player(@player) }, except: [:index, :show]

  before_action :pull_activity, only: [:show,
                                       :claim_steps,
                                       :claim_active_minutes,
  ]

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
    output = {
      status: 'ok',
      player: @player.as_json,
    }
    render json: output
  end

  # PATCH/PUT /players/1
  def update
    @player.update!(player_params)
    render :json => {
      status: 'ok',
      player: @player.as_json,
    }
  end

  def claim_steps
    @player.claim_steps!
    render_player
  end

  def claim_active_minutes
    @player.claim_active_minutes!
    render_player
  end

  def buy
    # require_player(@player) || return # todo: do this with a before_action

    if params['gear']
      @player.buy_gear!(params['gear']['name'])
    elsif params['ammo']
      @player.buy_ammo!(params['ammo']['name'])
    else
      raise "Must specify buying either gear or ammo"
    end
    render_player
  end

  def equip
    @player.equip_gear!(params['gear']['name'])
    render_player
  end

  def unequip
    @player.unequip_gear!(params['gear']['name'])
    render_player
  end

  def arrange
    ammo = params[:ammo]
    raise "parameter ammo required" if ammo.nil?
    ammo = [ammo] unless ammo.is_a? Array
    @player.arrange_ammo! ammo
    render_player
  end

  def arrange_ammo(ammo)
    @player.piece.update!(ammo: ammo)
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def player_params
    params.require(:player).permit(:name, :password, :team, :embodied)
  end


end
