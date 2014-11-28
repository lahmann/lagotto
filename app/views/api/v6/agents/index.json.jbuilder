json.agents @agents do |agent|
  json.cache! ['v6', agent], skip_digest: true do
    json.(agent, :id, :title, :source, :group, :status, :error_count, :articles, :jobs, :responses, :update_date, )
  end
end
