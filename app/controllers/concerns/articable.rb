module Articable
  extend ActiveSupport::Concern

  included do
    def show
      source_id = Source.where(name: params[:source]).pluck(:id).first

      # Load one article given query params
      id_hash = { :articles => Article.from_uri(params[:id]) }
      @article = ArticleDecorator.includes(:traces).where(id_hash)
        .decorate(context: { info: params[:info], source_id: source_id })

      # Return 404 HTTP status code and error message if article wasn't found
      if @article.blank?
        @error = "Article not found."
        render "error", :status => :not_found
      else
        @success = "Article found."
      end
    end

    def index
      # Load articles from ids listed in query string, use type parameter if present
      # Translate type query parameter into column name
      # Paginate query results, default is 50 articles per page

      if params[:ids]
        type = ["doi", "pmid", "pmcid", "mendeley_uuid"].find { |t| t == params[:type] } || Article.uid
        ids = params[:ids].nil? ? nil : params[:ids].split(",").map { |id| Article.clean_id(id) }
        collection = Article.where(:articles => { type.to_sym => ids })
      elsif params[:q]
        collection = Article.query(params[:q])
      elsif params[:source] && source = Source.find_by_name(params[:source])
        collection = Article.includes(:traces)
          .where("traces.source_id = ?", source.id)
          .where("traces.event_count > 0")
      else
        collection = Article
      end

      if params[:class_name]
        @class_name = params[:class_name]
        collection = collection.includes(:alerts)
        if @class_name == "All Alerts"
          collection = collection.where("alerts.unresolved = ?", true)
        else
          collection = collection.where("alerts.unresolved = ?", true).where("alerts.class_name = ?", @class_name)
        end
      end

      # sort by source event_count
      # we can't filter and sort by two different sources
      if params[:order] && source && params[:order] == params[:source]
        collection = collection.order("traces.event_count DESC")
      elsif params[:order] && !source && order = Source.find_by_name(params[:order])
        collection = collection.includes(:traces)
          .where("traces.source_id = ?", order.id)
          .order("traces.event_count DESC")
      else
        collection = collection.order("published_on DESC")
      end

      if params[:publisher] && publisher = Publisher.find_by_crossref_id(params[:publisher])
        collection = collection.where(publisher_id: params[:publisher])
      end

      per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50

      # use cached counts for total number of results
      total_entries = case
                      when params[:ids] || params[:q] then nil # can't be cached
                      when source && publisher then publisher.article_count_by_source(source.id)
                      when source then source.article_count
                      when publisher then publisher.article_count
                      else Article.count_all
                      end

      collection = collection.paginate(per_page: per_page,
                                       page: params[:page],
                                       total_entries: total_entries)
      @articles = collection.decorate(context: { info: params[:info],
                                                 source: params[:source],
                                                 user: current_user.cache_key })
    end

    protected

    def load_article
      # Load one article given query params
      id_hash = Article.from_uri(params[:id])
      if id_hash.respond_to?("key")
        key, value = id_hash.first
        @article = Article.where(key => value).decorate.first
      else
        @article = nil
      end
    end

    private

    def safe_params
      params.require(:article).permit(:doi, :title, :pmid, :pmcid, :mendeley_uuid, :canonical_url, :year, :month, :day)
    end
  end
end
