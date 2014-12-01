require 'cgi'

class Api::OembedController < ApplicationController
  before_filter :default_format_json
  respond_to :json, :xml

  def show
    url = CGI.unescape(params[:url])
    url = Rails.application.routes.recognize_path(url)

    # proceed if url was recognized
    if url[:action] == "show"
      id_hash = Work.from_uri(url[:id])
      work = Work.where(id_hash)
    end

    # raise an error if work wasn't found
    fail ActiveRecord::RecordNotFound unless url[:action] == "show" && work.present?

    @work = work.first.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })

  rescue ActiveRecord::RecordNotFound, ActionController::RoutingError
    # we need to rescue here so that we can also handle xml
    render :template => "api/oembed/not_found", :status => :not_found
  end
end
