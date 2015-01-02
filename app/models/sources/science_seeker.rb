# encoding: UTF-8

class ScienceSeeker < Source
  def request_options
    { content_type: 'xml' }
  end

  def get_events(result)
    events = result['feed'] && result.fetch("feed", {}).fetch("entry", nil)
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      event_time = get_iso8601_from_time(item["updated"])

      { "author" => get_authors([item.fetch('author', {}).fetch('name', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => item.fetch('source', {}).fetch('title', ""),
        "issued" => get_date_parts(event_time),
        "URL" => item.fetch("link", {}).fetch("href", nil),
        "type" => 'post' }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{doi}"
  end

  def events_url
    config.events_url || "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def workers
    config.workers || 3
  end
end
