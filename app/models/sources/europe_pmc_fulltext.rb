class EuropePmcFulltext < Source
  def get_query_url(work, options = {})
    return nil unless work.get_url

    url % { :query_string => work.query_string }
  end

  def get_events_url(work)
    return nil unless events_url.present? && work.query_string.present?

    events_url % { :query_string => work.query_string }
  end

  def parse_data(result, work, options={})
    return result if result[:error] || result["resultList"].nil?

    events = get_events(result, work)
    total = events.length

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: get_events_url(work),
      event_count: total,
      event_metrics: get_event_metrics(citations: total),
      extra: nil }
  end

  def get_events(result, work)
    result.fetch("resultList", {}).fetch("result", []).map do |item|
      doi = item.fetch("doi", nil)
      pmid = item.fetch("pmid", nil)
      url = doi ? "http://dx.doi.org/#{doi}" : "http://europepmc.org/abstract/MED/#{pmid}"
      author_string = item.fetch("authorString", "").chomp(".")

      { "author" => get_authors(author_string.split(", "), reversed: true),
        "title" => item.fetch("title", "").chomp("."),
        "container-title" => item.fetch("journalTitle", nil),
        "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
        "DOI" => doi,
        "PMID" => pmid,
        "URL" => url,
        "type" => "article-journal" }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%{query_string}&dataset=fulltext&format=json&resultType=lite"
  end

  def events_url
    config.events_url || "http://europepmc.org/search?scope=fulltext&query=%{query_string}"
  end
end
