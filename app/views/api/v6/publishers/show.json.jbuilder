json.publisher do
  json.cache! ['v6', @publisher], skip_digest: true do
    json.(@publisher, :id, :name, :other_names, :prefixes, :update_date)
  end

  if current_user && current_user.is_staff?
    json.(@publisher, :users)
  end
end
