json.docs @docs do |doc|
  json.cache! ['v6', @doc], skip_digest: true do
    json.(doc, :id, :title, :layout, :content, :update_date)
  end
end