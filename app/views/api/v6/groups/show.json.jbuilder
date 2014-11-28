json.group do
  json.cache! ['v6', @group], skip_digest: true do
    json.(@group, :id, :title, :sources, :agents, :update_date)
  end
end
