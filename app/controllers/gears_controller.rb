class GearsController < ApplicationController

  # GET /gears
  def index
    @gears = Gear.all
    render json: {status: 'ok', gears: @gears.as_json}
  end

end
