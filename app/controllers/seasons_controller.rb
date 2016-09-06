class SeasonsController < ApplicationController
  before_action :find_season

  # GET /seasons/1
  def show
    render_season
  end

end
