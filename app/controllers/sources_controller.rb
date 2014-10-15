class SourcesController < ApplicationController
  before_filter :load_source, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  respond_to :html, :js, :rss

  def show
    @doc = Doc.find(@source.name)
    @page = params[:page] || 1
    @publisher = Publisher.where(crossref_id: params[:publisher]).first
    @order = Source.active.where(name: params[:order]).first

    respond_with(@source) do |format|
      format.rss do
        if params[:days]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_days(params[:days].to_i)
        elsif params[:months]
          @retrieval_statuses = @source.retrieval_statuses.most_cited_last_x_months(params[:months].to_i)
        else
          @retrieval_statuses = @source.retrieval_statuses.most_cited
        end
        render :show
      end
    end
  end

  def index
    @doc = Doc.find("sources")

    @groups = Group.includes(:sources).order("groups.id, sources.display_name")
  end

  def edit
    respond_with(@source) do |format|
      format.js { render :show }
    end
  end

  def update
    params[:source] ||= {}
    params[:source][:active] = params[:active] if params[:active]
    @source.update_attributes(safe_params)
    if @source.invalid?
      error_messages = @source.errors.full_messages.join(', ')
      flash.now[:alert] = "Please configure source #{@source.display_name}: #{error_messages}"
      @flash = flash
    end
    respond_with(@source) do |format|
      if params[:active]
        @groups = Group.includes(:sources).order("groups.id, sources.display_name")
        format.js { render :index }
      else
        format.js { render :show }
      end
    end
  end

  protected

  def load_source
    @source = Source.find_by_name(params[:id])

    # raise error if source wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?
  end

  private

  def safe_params
    params.require(:source).permit(:display_name,
                                   :group_id,
                                   :private,
                                   :description,
                                   :active)
  end
end
