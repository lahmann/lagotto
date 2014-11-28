json.source do
  json.cache! ['v6', @source], skip_digest: true do
    json.(@source, :id, :title, :group, :description, :update_date, :status)

    unless params[:info] == "summary"
      json.(@source, :work_count, :event_count, :error_count, :by_day, :by_month)
    end
  end
end
