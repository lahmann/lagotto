json.total @works.total_entries
json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
json.page @works.total_entries > 0 ? @works.current_page : 0
json.error @error

json.data @works do |work|
  json.cache! ['v5', work], skip_digest: true do
    json.(work, :doi, :title, :issued, :canonical_url, :pmid, :pmcid, :mendeley_uuid, :viewed, :saved, :discussed, :cited, :update_date)

    unless params[:info] == "summary"
      json.sources work.retrieval_statuses do |rs|
        json.cache! ['v5', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date)
          json.metrics rs.new_metrics
          json.events rs.events_csl if params[:info] == "detail"
        end
      end
    end
  end
end
