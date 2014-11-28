class Api::V6::DepositsController < Api::V6::BaseController
  # load_and_authorize_resource

  def create
    @deposit = Deposit.new(deposit_params)
    @deposit.user = current_user
    @deposit.source = Source.where(name: params[:deposit][:source_id]).first

    if @deposit.save
      @deposit = @deposit.decorate
      render :show, :status => :created
    else
      render :error, :status => :bad_request
    end
  end

  def show
    @deposit = Deposit.where(uuid: params[:id]).first
    @deposit = @deposit.decorate
  end

  def destroy
    @deposit.destroy
  end

  private

  def deposit_params
    params.require(:deposit).permit(:source_id, { data: [:doi,
                                                         :source,
                                                         :events,
                                                         :events_by_day,
                                                         :events_by_month,
                                                         :events_url,
                                                         :event_count,
                                                         :event_metrics] })
  end
end
