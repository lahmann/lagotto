class Api::SourcesController < ApplicationController
  skip_authorize_resource

  def show
    @source = Source.where(name: params[:id]).first

    if @source.blank?
      @error = "No record for \"#{params[:id]}\" found"
      render :error, status: :not_found
    elsif params[:days]
      @traces = @source.traces.most_cited
                .published_last_x_days(params[:days].to_i)
    elsif params[:months]
      @traces = @source.traces.most_cited
                .published_last_x_months(params[:months].to_i)
    else
      @traces = @source.traces.most_cited
    end
  end
end
