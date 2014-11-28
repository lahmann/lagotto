class Datacite < Agent
  def get_events(result)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map { |item| { event: item, event_url: "http://doi.org/#{item['doi']}" } }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json"
  end

  def events_url
    config.events_url || "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end
end
