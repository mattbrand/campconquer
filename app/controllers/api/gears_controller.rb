module API
  class GearsController < APIController

    # GET /gears
    def index
      @gears = Gear.all
      render json: {status: 'ok', gears: @gears.as_json}
    end

  end
end
