class WebController < ApplicationController
  # todo: pretty error page for web
  def render_error (status: :internal_server_error, message:)
    render status: status,
           text: "Error: #{message}"
  end

end
