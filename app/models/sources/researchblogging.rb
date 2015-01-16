# encoding: UTF-8

class Researchblogging < Source
  def request_options
    { content_type: 'xml', username: username, password: password }
  end

  def get_events(result)
    events = result.fetch("blogposts", {}).fetch("post", nil)
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("published_date", nil))

      { "author" => get_authors([item.fetch('blogger_name', nil)]),
        "title" => item.fetch('post_title', "No title"),
        "container-title" => item.fetch('blog_name', nil),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("post_URL", nil),
        "type" => 'post' }
    end
  end

  def config_fields
    [:url, :events_url, :username, :password]
  end

  def url
    config.url || "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{doi}"
  end

  def events_url
    config.events_url || "http://researchblogging.org/post-search/list?article=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 2000
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def workers
    config.workers || 3
  end
end
