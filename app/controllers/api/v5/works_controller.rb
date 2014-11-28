class Api::V5::WorksController < Api::V5::BaseController

  def show
    source_id = Source.where(name: params[:source]).pluck(:id).first

    # Load one work given query params
    id_hash = { :works => Work.from_uri(params[:id]) }
    @work = WorkDecorator.includes(:retrieval_statuses)
      .references(:retrieval_statuses)
      .where(id_hash).first
      .decorate(context: { info: params[:info], source_id: source_id })

    # Return 404 HTTP status code and error message if work wasn't found
    if @work.blank?
      @error = "Work not found."
      render "error", :status => :not_found
    else
      fresh_when last_modified: @work.updated_at

      @success = "Work found."
    end
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
    elsif params[:source] && source = Source.where(name: params[:source]).first
      collection = Work.joins(:retrieval_statuses)
                   .where("retrieval_statuses.source_id = ?", source.id)
                   .where("retrieval_statuses.event_count > 0")
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
    if params[:order] && source && params[:order] == params[:source]
      collection = collection.order("retrieval_statuses.event_count DESC")
    elsif params[:order] && !source && order = Source.where(name: params[:order]).first
      collection = collection.joins(:retrieval_statuses)
        .where("retrieval_statuses.source_id = ?", order.id)
        .order("retrieval_statuses.event_count DESC")
    else
      collection = collection.order("published_on DESC")
    end

    if params[:publisher] && publisher = Publisher.where(crossref_id: params[:publisher]).first
      collection = collection.where(publisher_id: params[:publisher])
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
                                            source: params[:source],
                                            is_staff: is_staff? })
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = Work.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first.decorate
    else
      @work = nil
    end
  end
end
