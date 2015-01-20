# encoding: UTF-8

class Reddit < Source
  def parse_data(result, work, options={})
    return result if result[:error]

    events = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(events, 'data', 'score')
    comments = get_sum(events, 'data', 'num_comments')
    total = likes + comments

    events = get_events(events)
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(work),
      event_count: total,
      event_metrics: get_event_metrics(comments: comments, likes: likes, total: total) }
  end

  def get_events(result)
    result.map do |item|
      data = item['data']
      timestamp = get_iso8601_from_epoch(data.fetch("created_utc", nil))

     {
        "author" => get_authors([data.fetch('author', "")]),
        "title" => data.fetch('title', nil),
        "container-title" => 'Reddit',
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "url" => data.fetch("url", nil),
        "type" => 'personal_communication' }
    end
  end

  def get_query_url(work, options = {})
    return nil unless url.present? && work.get_url

    url % { query_string: work.query_string }
  end

  def get_events_url(work)
    return nil unless events_url.present? && work.get_url

    events_url % { query_string: work.query_string }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.reddit.com/search.json?q=%{query_string}&limit=100"
  end

  def events_url
    config.events_url || "http://www.reddit.com/search?q=%{query_string}"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1800
  end
end
