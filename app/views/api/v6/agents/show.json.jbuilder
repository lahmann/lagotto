json.agent do
  json.cache! ['v6', @agent], skip_digest: true do
    json.(@agent, :id, :title, :source, :group, :status, :error_count, :status, :articles, :jobs, :responses, :update_date)
  end
end
