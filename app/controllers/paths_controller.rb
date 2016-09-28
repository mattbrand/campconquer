class PathsController < ApplicationController

  # GET /paths
  def index
    @paths = Path.all
    render json: {status: 'ok', paths: @paths.as_json}
  end

end
