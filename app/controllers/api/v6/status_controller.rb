class Api::V6::StatusController < Api::V6::BaseController
  def index
    @status = [Status.new]
  end

  # flash.now[:alert] = "Your Lagotto software is outdated, please install <a href='https://github.com/articlemetrics/lagotto/releases'>version #{@status.current_version}</a>.".html_safe
end
