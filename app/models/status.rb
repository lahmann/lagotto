class Status
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  RELEASES_URL = "https://api.github.com/repos/articlemetrics/lagotto/releases"

  def id
    1
  end

  def works_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/works_count/#{update_date}").to_i
    else
      Work.count
    end
  end

  def works_count=(timestamp)
    Rails.cache.write("status/works_count/#{timestamp}", Work.count)
  end

  def works_last30_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/works_last30_count/#{update_date}").to_i
    else
      Work.last_x_days(30).count
    end
  end

  def works_last30_count=(timestamp)
    Rails.cache.write("status/works_last30_count/#{timestamp}",
                      Work.last_x_days(30).count)
  end

  def events_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/events_count/#{update_date}").to_i
    else
      Trace.joins(:source).where("name != ?", "relativemetric").sum(:event_count)
    end
  end

  def events_count=(timestamp)
    Rails.cache.write("status/events_count/#{timestamp}",
                      Trace.joins(:source)
                        .where("name != ?", "relativemetric").sum(:event_count))
  end

  def notifications_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/notifications_count/#{update_date}").to_i
    else
      Notification.count
    end
  end

  def notifications_count=(timestamp)
    Rails.cache.write("status/notifications_count/#{timestamp}",
                      Notification.count)
  end

  def workers
    Worker.active
  end

  def workers_count
    Worker.active.length
  end

  def delayed_jobs_active_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/delayed_jobs_active_count/#{update_date}").to_i
    else
      DelayedJob.count
    end
  end

  def delayed_jobs_active_count=(timestamp)
    Rails.cache.write("status/delayed_jobs_active_count/#{timestamp}",
                      DelayedJob.count)
  end

  def responses_count
    if ActionController::Base.perform_caching
      Rails.cache.read("status/responses_count/#{update_date}").to_i
    else
      ApiResponse.total(1).count
    end
  end

  def responses_count=(timestamp)
    Rails.cache.write("status/responses_count/#{timestamp}",
                      ApiResponse.total(1).count)
  end

  def requests_count
    if ActionController::Base.perform_caching
      Rails.cache.fetch("status/requests_count/#{update_date}").to_i
    else
      ApiRequest.total(1).count
    end
  end

  def requests_count=(timestamp)
    Rails.cache.write("status/requests_count/#{timestamp}",
                      ApiRequest.total(1).count)
  end

  def users_count
    User.count
  end

  def sources_active_count
    Source.active.count
  end

  def agents
    { "working" => Agent.working.count,
      "waiting" => Agent.waiting.count,
      "disabled" => Agent.disabled.count,
      "inactive" => Agent.inactive.count }
  end

  def version
    Rails.application.config.version
  end

  def current_version
    if ActionController::Base.perform_caching
      Rails.cache.read("status/current_version/#{update_date}") || version
    else
      result = get_result(RELEASES_URL)
      result = result.is_a?(Array) ? result.first : {}
      result.fetch("tag_name", "v.#{version}")[2..-1]
    end
  end

  def current_version=(timestamp)
    result = get_result(RELEASES_URL)
    result = result.is_a?(Array) ? result.first : {}
    Rails.cache.write("status/current_version/#{timestamp}",
                      result.fetch("tag_name", "v.#{version}")[2..-1])
  end

  def outdated_version
    Gem::Version.new(current_version) > Gem::Version.new(version)
  end

  alias_method :outdated_version?, :outdated_version

  def couchdb_size
    get_lagotto_database["disk_size"] || 0
  end

  def update_date
    if ActionController::Base.perform_caching
      Rails.cache.read("status:timestamp") || "1970-01-01T00:00:00Z"
    else
      Time.zone.now.utc.iso8601
    end
  end

  def update_date=(timestamp)
    Rails.cache.write("status:timestamp", timestamp)
  end

  def cache_key
    "status/#{update_date}"
  end

  def update_cache
    DelayedJob.delete_all(queue: "status-cache")
    delay(priority: 1, queue: "status-cache").write_cache
  end

  def write_cache
    # update cache_key as last step so that old version works until we are done
    timestamp = Time.zone.now.utc.iso8601

    # loop through cached attributes we want to update
    [:works_count,
     :works_last30_count,
     :events_count,
     :notifications_count,
     :delayed_jobs_active_count,
     :responses_count,
     :requests_count,
     :current_version,
     :update_date].each { |cached_attr| send("#{cached_attr}=", timestamp) }
  end
end
