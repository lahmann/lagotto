require 'cgi'

class Api::OembedController < ApplicationController
  before_filter :default_format_json
  respond_to :json, :xml

  def show
    if params[:url]
      url = CGI.unescape(params[:url])
      url = Rails.application.routes.recognize_path(url)
    else
      url = {}
    end

    # proceed if url was recognized
    if url[:action] == "show"
      id_hash = Work.from_uri(url[:id])
      work = Work.where(id_hash)
    end

    # proceed if work was found
    if url[:action] == "show" && work.first
      @work = work.first.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })
    else
      render :template => "api/oembed/not_found", :status => :not_found
    end
  end
end
