class Api::V3::WorksController < Api::V3::BaseController
  def index
    # Filter by source parameter, filter out private sources unless admin
    # Load works from ids listed in query string, use type parameter if present
    # Translate type query parameter into column name
    # Limit number of ids to 50
    source_ids = get_source_ids(params[:source])

    type = { "doi" => :doi, "pmid" => :pmid, "pmcid" => :pmcid, "mendeley" => :mendeley_uuid }.values_at(params[:type]).first || Work.uid_as_sym

    ids = params[:ids].nil? ? nil : params[:ids].split(",")[0...50].map { |id| Work.clean_id(id) }
    id_hash = { :works => { type => ids }, :traces => { :source_id => source_ids }}
    @works = WorkDecorator.includes(:traces).references(:traces)
                .where(id_hash)
                .order("works.updated_at DESC")

    # Return 404 HTTP status code and error message if work wasn't found, or no valid source specified
    if @works.blank?
      if params[:source].blank?
        @error = "Article not found."
      else
        @error = "Source not found."
      end
      render json: { error: @error }, status: :not_found
    else
      fresh_when last_modified: @works.maximum(:updated_at)

      @works = @works.decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
    end
  end

  def show
    # Load one work given query params
    source_ids = get_source_ids(params[:source])

    id_hash = { :works => Work.from_uri(params[:id]), :traces => { :source_id => source_ids }}
    @work = Work.includes(:traces).references(:traces)
               .where(id_hash).first


    # Return 404 HTTP status code and error message if work wasn't found, or no valid source specified
    if @work.blank?
      if params[:source].blank?
        @error = "Article not found."
      else
        @error = "Source not found."
      end
      render json: { error: @error }, status: :not_found
    else
      fresh_when last_modified: @work.updated_at

      @work = @work.decorate(context: { days: params[:days], months: params[:months], year: params[:year], info: params[:info], source: params[:source] })
    end
  end

  protected

  def load_work
    # Load one work given query params
    id_hash = Work.from_uri(params[:id])
    if id_hash.respond_to?("key")
      key, value = id_hash.first
      @work = Work.where(key => value).first
    else
      @work = nil
    end
  end

  # Filter by source parameter, filter out private sources unless admin
  def get_source_ids(source_names)
    if source_names && is_staff?
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif is_staff?
      source_ids = Source.order("name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("name").pluck(:id)
    end
  end
end
