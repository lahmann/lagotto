# encoding: UTF-8

class Scopus < Source
  def request_options
    { :headers => { "X-ELS-APIKEY" => api_key, "X-ELS-INSTTOKEN" => insttoken } }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = result.fetch("search-results", {}).fetch("entry", []).first

    if extra && extra["link"]
      event_count = extra.fetch("citedby-count", nil).to_i
      link = extra["link"].find { |link| link["@ref"] == "scopus-citedby" }
      events_url = link.fetch("@href", nil)
    else
      event_count = 0
      events_url = nil
    end

    { events: [],
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count),
      extra: extra }
  end

  def config_fields
    [:url, :api_key, :insttoken]
  end

  def url
    config.url  || "https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(%{doi})"
  end

  def insttoken
    config.insttoken
  end

  def insttoken=(value)
    config.insttoken = value
  end
end
