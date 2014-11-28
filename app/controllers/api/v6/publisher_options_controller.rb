class Api::V6::PublisherOptionsController < Api::V6::BaseController
  # load_and_authorize_reagent

  def show
    @publisher_option.config = @agent.publisher_fields if @publisher_option.config.nil?
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  def edit
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  def update
    @publisher_option.update_attributes(safe_params)
    respond_with(@publisher_option) do |format|
      format.js { render :show }
    end
  end

  protected

  def load_agent
    @agent = Agent.where(name: params[:agent_id]).first
    @publisher_option = PublisherOption.where(publisher_id: params[:id], agent_id: @agent.id).first_or_create

    # raise error if publisher_option wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @publisher_option.blank?
  end

  private

  def safe_params
    params.require(:publisher_option).permit(*@agent.publisher_fields)
  end
end
