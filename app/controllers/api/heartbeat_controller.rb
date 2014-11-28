class Api::HeartbeatController < ApplicationController
  before_filter :default_format_json
  after_filter :cors_set_access_control_headers, :set_jsonp_format

  def show
    @status = Status.new
  end
end
