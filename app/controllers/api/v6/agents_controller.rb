class Api::V6::AgentsController < Api::V6::BaseController
  before_filter :load_agent, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
    collection = Agent.visible.includes(:group).references(:group)
    @agents = collection.decorate
  end

  def show
  end

  def edit
  end

  def update
    params[:agent] ||= {}
    params[:agent][:state_event] = params[:state_event] if params[:state_event]
    @agent.update_attributes(safe_params)
    if @agent.invalid?
      error_messages = @agent.errors.full_messages.join(', ')
    end

    @groups = Group.includes(:agents).order("groups.id, agents.title") if params[:state_event]
  end

  protected

  def load_agent
    @agent = Agent.where(name: params[:id]).first

    # raise error if agent wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @agent.blank?

    @agent = @agent.decorate
  end

  private

  def safe_params
    params.require(:agent).permit(:title,
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
