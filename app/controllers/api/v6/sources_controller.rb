class Api::V6::SourcesController < Api::V6::BaseController
  before_filter :load_source, only: [:show, :edit, :update]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def show
    @order = params[:order] == @source.name ? @source : nil
    @source = source.decorate
  end

  def index
    @doc = Doc.find("sources")
    @doc = DocDecorator.decorate(@doc)

    collection = Source.active
    @sources = collection.decorate

    @groups = Group.includes(:sources).order("groups.id, sources.title")
  end

  def edit
    @source = source.decorate
  end

  def update
    params[:source] ||= {}
    params[:source][:active] = params[:active] if params[:active]
    @source.update_attributes(safe_params)

    @error = @source.errors.full_messages.join(', ') if @source.invalid?
  end

  protected

  def load_source
    @source = Source.where(name: params[:id]).first

    # raise error if source wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:id]}\" found" if @source.blank?
  end

  private

  def safe_params
    params.require(:source).permit(:title,
                                   :group_id,
                                   :active,
                                   :private,
                                   :by_publisher,
                                   :description)
  end
end
