json.success @success
json.error @error

json.cache! ['v6', @work], skip_digest: true do
  json.work do
    json.(@work, :id, :doi, :pmid, :pmcid, :url, :canonical_url, :title, :issued, :viewed, :saved, :discussed, :cited, :update_date)

    unless params[:info] == "summary"
      json.sources @work.traces do |trace|
        json.(trace, :name, :title, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date)
        json.metrics trace.new_metrics
        json.events trace.events_csl if params[:info] == "detail"
      end
    end
  end
end
