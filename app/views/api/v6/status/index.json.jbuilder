json.status @status do |status|
  json.cache! ['v6', status], skip_digest: true do
    json.(status, :id, :works_count, :works_last30_count, :responses_count, :events_count, :requests_count, :sources_active_count, :version, :outdated_version)

    if current_user && current_user.is_staff?
      json.(status, :alerts_count, :delayed_jobs_active_count, :workers, :agents, :users_count, :couchdb_size)
    end

    json.update_date status.update_date
  end
end
