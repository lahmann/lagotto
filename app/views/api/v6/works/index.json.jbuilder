json.meta do
  json.total @works.total_entries
  json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
  json.page @works.total_entries > 0 ? @works.current_page : 0
end

json.works @works do |work|
  json.cache! ['v6', work], skip_digest: true do
    json.(work, :id, :doi, :pmid, :pmcid, :url, :canonical_url, :title, :issued, :viewed, :saved, :discussed, :cited, :update_date)

    unless params[:info] == "summary"
      json.sources work.filtered_traces do |trace|
        json.cache! ['v6', trace, params[:info]], skip_digest: true do
          json.(trace, :name, :title, :group, :events_url, :by_day, :by_month, :by_year, :update_date)
          json.metrics trace.new_metrics
          json.(trace, :events, :events_csl) if params[:info] == "detail"
        end
      end
    end
  end
end
