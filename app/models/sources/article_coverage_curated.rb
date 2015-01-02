# encoding: UTF-8

class ArticleCoverageCurated < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { doi: work.doi_escaped }
  end

  def response_options
    { metrics: :comments }
  end

  def get_events(result)
    Array(result.fetch("referrals", nil)).map do |item|
      event_time = get_iso8601_from_time(item['published_on'])

      { "author" => nil,
        "title" => item.fetch("title", nil),
        "container-title" => item.fetch("publication", nil),
        "issued" => get_date_parts(event_time),
        "URL" => item.fetch("referral", nil),
        "type" => get_csl_type(item.fetch("type", nil)) }
    end
  end

  def get_csl_type(type)
    return nil if type.blank?

    types = { 'Blog' => 'post',
              'News' => 'article-newspaper',
              'Podcast/Video' => 'broadcast',
              'Lab website/homepage' => 'webpage',
              'University page' => 'webpage' }
    types[type]
  end

  def config_fields
    [:url]
  end
end
