# encoding: UTF-8

class Nature < Source
  def get_events(result)
    Array(result['data']).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("post", {}).fetch("created_at", nil))
      url = item.fetch("post", {}).fetch("url", nil)
      url = "http://#{url}" unless url.blank? || url.start_with?("http://")

      { "author" => nil,
        "title" => item.fetch("post", {}).fetch("title", nil),
        "container-title" => item.fetch("post", {}).fetch("blog", {}).fetch("title", nil),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'post' }
    end
  end

  def config_fields
    [:url]
  end

  def url
    config.url || "http://blogs.nature.com/posts.json?doi=%{doi}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 5000
  end
end
