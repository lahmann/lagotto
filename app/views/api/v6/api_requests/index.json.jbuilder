json.total @api_requests.total_entries
json.total_pages (@api_requests.total_entries.to_f / @api_requests.per_page).ceil
json.page @api_requests.total_entries > 0 ? @api_requests.current_page : 0

json.api_requests @api_requests do |api_request|
  json.(api_request, :id, :api_key, :info, :source, :ids, :db_duration, :view_duration, :date)
end
