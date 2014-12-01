class Api::V6::EventsController < Api::V6::BaseController
  # load_and_authorize_resource

  def show

  end

  def create
    @event = Event.new(event_params)
    @event.source = Source.where(name: params[:event][:source_id]).first

    if @event.save
      @event = @event.decorate
      render :show, :status => :created
    else
      render :error, :status => :bad_request
    end
  end

  def show
    @event = Deposit.where(id: params[:id]).first
    @event = @event.decorate
  end

  def destroy
    @event.destroy
  end

  private

  def event_params
    params.require(:event).permit(:source_id,
                                  :work_id,
                                  :title,
                                  :cotainer_title,
                                  :author,
                                  :doi,
                                  :url,
                                  :published_on,
                                  :type)
  end

end
