module API
  class SeasonsController < APIController
    before_action :find_season

    # GET /seasons/1
    def show
      render_season
    end

  end
end
