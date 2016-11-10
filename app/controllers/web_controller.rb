class WebController < ApplicationController
  # todo: pretty error page for web
  def render_error (status: :internal_server_error, message:)
    render status: status,
           layout: 'application',
           html: "<div class='error'><b>Error:</b>".html_safe + " #{message}" + "</div>".html_safe
  end

end
