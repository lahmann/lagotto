json.meta do
  json.total @notifications.total_entries
  json.total_pages (@notifications.total_entries.to_f / @notifications.per_page).ceil
  json.page @notifications.total_entries > 0 ? @notifications.current_page : 0
end

json.notifications @notifications do |notification|
  json.cache! ['v6', notification], skip_digest: true do
    json.(notification, :id, :level, :class_name, :message, :status, :hostname, :target_url, :source, :agent, :work, :unresolved, :create_date)
  end
end
