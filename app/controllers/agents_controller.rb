class AgentsController < ApplicationController
  before_filter :load_agent, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  respond_to :html, :js

  def show
    @doc = Doc.find(@agent.name)
    if current_user && current_user.publisher && @agent.by_publisher?
      @publisher_option = PublisherOption.find_or_create_by_publisher_id_and_agent_id(current_user.publisher_id, @agent.id)
    end
  end

  def index
    @doc = Doc.find("agents")

    @groups = Group.includes(:sources, :agents).order("groups.id, agents.display_name")
  end

  def edit
    respond_with(@agent) do |format|
      format.js { render :show }
    end
  end

  def update
    params[:agent] ||= {}
    params[:agent][:state_event] = params[:state_event] if params[:state_event]
    @agent.update_attributes(safe_params)
    if @agent.invalid?
      error_messages = @agent.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure agent #{@agent.display_name}: #{error_messages}"
      @flash = flash
    end
    respond_with(@agent) do |format|
      if params[:state_event]
        @groups = Group.includes(:agents).order("groups.id, agents.display_name")
        format.js { render :index }
      else
        format.js { render :show }
      end
    end
  end

  protected

  def load_agent
    @agent = Agent.find_by_name(params[:id])

    # raise error if agent wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @agent.blank?
  end

  private

  def safe_params
    params.require(:agent).permit(:display_name,
                                   :group_id,
                                   :state_event,
                                   :private,
                                   :by_publisher,
                                   :queueable,
                                   :description,
                                   :job_batch_size,
                                   :priority,
                                   :workers,
                                   :rate_limiting,
                                   :wait_time,
                                   :staleness_week,
                                   :staleness_month,
                                   :staleness_year,
                                   :staleness_all,
                                   :cron_line,
                                   :timeout,
                                   :max_failed_queries,
                                   :max_failed_query_time_interval,
                                   :disable_delay,
                                   :url,
                                   :url_with_type,
                                   :url_with_title,
                                   :related_articles_url,
                                   :api_key,
                                   *@agent.config_fields)
  end
end
