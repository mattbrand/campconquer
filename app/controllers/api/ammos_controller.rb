module API
  class AmmosController < APIController

    # GET /ammos
    def index
      @ammos = Ammo.all
      render json: {status: 'ok', ammos: @ammos.as_json}
    end

  end
end
