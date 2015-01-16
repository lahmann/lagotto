class ArticleCoverage < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { doi: work.doi_escaped }
  end

  def response_options
    { metrics: :comments }
  end

  def get_events(result)
    Array(result.fetch("referrals", nil)).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("published_on", nil))

      { "author" => nil,
        "title" => item.fetch("title", "No title"),
        "container-title" => item.fetch("publication", nil),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("referral", nil),
        "type" => get_csl_type(item.fetch("type", nil)) }
    end
  end

  def get_csl_type(type)
    MEDIACURATION_TYPE_TRANSLATIONS.fetch(type, nil)
  end

  def config_fields
    [:url]
  end
end
