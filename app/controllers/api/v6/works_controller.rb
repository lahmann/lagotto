class Api::V6::WorksController < Api::V6::BaseController
  before_filter :load_work, only: [:show, :update, :destroy]

  def show
    fresh_when last_modified: @work.updated_at

    @work = @work.includes(:traces).references(:traces)
    .decorate(context: { info: params[:info], source_id: @source_id })
  end

  def index
    # Load works from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Paginate query results, default is 50 works per page

    if params[:ids]
      type = ["doi", "pmid", "pmcid"].find { |t| t == params[:type] } || Work.uid
      ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Work.clean_id(id) }
      collection = Work.where(:works => { type.to_sym => ids })
    elsif params[:q]
      collection = Work.query(params[:q])
    elsif params[:source_id] && source = Source.where(name: params[:source_id]).first
      collection = Work.joins(:traces)
                   .where("traces.source_id = ?", source.id)
                   .where("traces.event_count > 0")
    else
      collection = Work
    end

    if params[:class_name]
      @class_name = params[:class_name]
      collection = collection.includes(:notifications).references(:notifications)
      if @class_name == "All Notifications"
        collection = collection.where("notifications.unresolved = ?", true)
      else
        collection = collection.where("notifications.unresolved = ?", true).where("notifications.class_name = ?", @class_name)
      end
    end

    # sort by source event_count
    # we can't filter and sort by two different sources
    if params[:order] && source && params[:order] == params[:source_id]
      collection = collection.order("traces.event_count DESC")
    elsif params[:order] && !source && order = Source.where(name: params[:order]).first
      collection = collection.joins(:traces)
        .where("traces.source_id = ?", order.id)
        .order("traces.event_count DESC")
    else
      collection = collection.order("published_on DESC")
    end

    if params[:publisher_id] && publisher = Publisher.where(crossref_id: params[:publisher_id]).first
      collection = collection.where(publisher_id: params[:publisher_id])
    end

    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50

    # use cached counts for total number of results
    total_entries = case
                    when params[:ids] || params[:q] || params[:class_name] then nil # can't be cached
                    when source && publisher then publisher.work_count_by_source(source.id)
                    when source then source.work_count
                    when publisher then publisher.work_count
                    else Work.count_all
                    end

    collection = collection.paginate(per_page: per_page,
                                     page: params[:page],
                                     total_entries: total_entries)

    fresh_when last_modified: collection.maximum(:updated_at)

    @works = collection.decorate(context: { info: params[:info],
                                            source: params[:source_id],
                                            is_staff: is_staff? })
  end

  def create
    @work = Work.new(safe_params)
    authorize! :create, @work

    if @work.save
      @work = @work.includes(:traces).references(:traces)
      .decorate(context: { info: params[:info], source_id: nil })

      render "show", :status => :created
    else
      render json: { error: @work.errors }, status: :bad_request
    end
  end

  def update
    authorize! :update, @work

    if @work.update_attributes(safe_params)
      @work = @work.includes(:traces).references(:traces)
      .decorate(context: { info: params[:info], source_id: @source_id })

      render "show", :status => :ok
    else
      render json: { error: @work.errors }, status: :bad_request
    end
  end

  def destroy
    authorize! :destroy, @work

    if @work.destroy
      render json: {}, status: :ok
    else
      render json: { error: "An error occured." }, status: :bad_request
    end
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = Work.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
      @source_id = Source.where(name: params[:source_id]).pluck(:id).first
    else
      render json: { error: "Work not found." }, status: :not_found
    end
  end

  private

  def safe_params
    params.require(:work).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
  end
end
