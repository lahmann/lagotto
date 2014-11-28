json.filters @filters do |filter|
  json.cache! ['v6', filter], skip_digest: true do
    json.(filter, :id, :title, :description, :status, :update_date)
  end
end
