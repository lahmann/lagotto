class Api::V6::PublishersController < Api::V6::BaseController
  before_filter :load_publisher, only: [:show, :update, :destroy]
  before_filter :new_publisher, only: [:create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :index]

  def index
    load_index
  end

  def show
    @page = params[:page] || 1
    @source = Source.active.where(name: params[:source]).first
    @order = Source.active.where(name: params[:order]).first
  end

  def new
    if params[:query]
      ids = Publisher.pluck(:crossref_id)
      publishers = MemberList.new(query: params[:query], per_page: 10).publishers
      @publishers = publishers.reject { |publisher| ids.include?(publisher.crossref_id) }
    else
      @publishers = []
    end
  end

  def create
    @publisher.save
    load_index
  end

  def destroy
    @publisher.destroy
  end

  def new_publisher
    params[:publisher] = JSON.parse(params[:publisher], symbolize_names: true)
    @publisher = Publisher.new(safe_params)
  end

  protected

  def load_publisher
    @publisher = Publisher.where(crossref_id: params[:id]).first

    @publisher = @publisher.decorate
  end

  def load_index
    collection = Publisher.order(:name).paginate(:page => params[:page]).all

    @publishers = collection.decorate
  end

  private

  def safe_params
    params.require(:publisher).permit(:name, :crossref_id, :other_names=> [], :prefixes => [])
  end
end

