class PlosFulltext < Source
  def get_query_url(work, options = {})
    return nil unless work.get_url || work.doi !~ /^10.1371/

    query_string = get_query_string(work)
    return nil unless url.present? && query_string.present?

    url % { query_string: query_string }
  end

  def get_events_url(work)
    query_string = get_query_string(work)
    return nil unless events_url.present? && query_string.present?

    events_url % { query_string: query_string }
  end

  def get_query_string(work)
    return nil unless work.doi.present? || work.canonical_url.present?

    [work.doi, work.canonical_url].compact.map { |i| "everything:%22#{i}%22" }.join("+OR+")
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["response"].nil?

    events = get_events(result, work)
    total = events.length
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(citations: total),
      extra: nil }
  end

  def get_events(result, work)
    result.fetch("response", {}).fetch("docs", []).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("publication_date", nil))
      doi = item.fetch("id", nil)

      { "author" => get_authors(item.fetch("author_display", [])),
        "title" => item.fetch("title", ""),
        "container-title" => item.fetch("cross_published_journal_name", []).first,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "DOI" => doi,
        "URL" => "http://dx.doi.org/#{doi}",
        "type" => "article-journal" }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://api.plos.org/search?q=%{query_string}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000"
  end

  def events_url
    config.events_url || "http://www.plosone.org/search/advanced?unformattedQuery=%{query_string}"
  end
end
