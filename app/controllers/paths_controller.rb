class PathsController < ApplicationController

  # GET /paths
  def index
    @paths = Path.from_csv
    render json: {status: 'ok', paths: @paths.as_json}
  end

end
