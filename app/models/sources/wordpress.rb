# encoding: UTF-8

class Wordpress < Source
  def get_events(result)
    result['data'] = nil if result['data'].is_a?(String)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_epoch(item["epoch_time"])
      url = item['link']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('author', "")]),
          'title' => item.fetch('title') { '' },
          'container-title' => '',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post'
        }
      }
    end
  end

  def get_query_url(work, options = {})
    return nil unless url.present? && work.get_url

    url % { query_string: work.query_string }
  end

  def get_events_url(work)
    return nil unless events_url.present? && work.query_string.present?

    events_url % { :query_string => work.query_string }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://en.search.wordpress.com/?q=%{query_string}&t=post&f=json&size=20"
  end

  def events_url
    config.events_url || "http://en.search.wordpress.com/?q=%{query_string}&t=post"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
