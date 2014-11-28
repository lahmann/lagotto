json.cache! ['v3', @work], skip_digest: true do
  json.(@work, :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations)

  unless params[:info] == "summary"
    json.sources @work.traces do |trace|
      json.cache! ['v3', trace, params[:info]], skip_digest: true do
        json.(trace, :name, :display_name, :events_url, :metrics, :update_date)
        json.events trace.events if ["detail","event"].include?(params[:info])
        json.(trace, :by_day, :by_month, :by_year) if ["detail","history"].include?(params[:info])
      end
    end
  end
end
