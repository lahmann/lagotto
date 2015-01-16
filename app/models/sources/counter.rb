# encoding: UTF-8

class Counter < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { :doi => work.doi_escaped }
  end

  def request_options
    { content_type: "xml"}
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = get_extra(result)

    pdf = get_sum(extra, :pdf_views)
    html = get_sum(extra, :html_views)
    xml = get_sum(extra, :xml_views)
    total = pdf + html + xml

    { events: [],
      events_by_day: [],
      events_by_month: get_events_by_month(extra),
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total),
      extra: extra }
  end

  def get_extra(result)
    events = result.fetch("rest", {}).fetch("response", {}).fetch("results", {}).fetch("item", nil)
    events = [events] if events.is_a?(Hash)
    Array(events).map do |item|
      { month: item.fetch("month", nil),
        year: item.fetch("year", nil),
        pdf_views: item.fetch("get_pdf", 0),
        xml_views: item.fetch("get_xml", 0),
        html_views: item.fetch("get_document", 0) }
    end
  end

  def get_events_by_month(extra)
    extra.map do |item|
      { month: item[:month].to_i,
        year: item[:year].to_i,
        html: item[:html_views].to_i,
        pdf: item[:pdf_views].to_i }
    end
  end

  # Format Counter events for all works as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "xml", "combined"].include? options[:format]
      view = "counter_#{options[:format]}_views"
    else
      view = "counter"
    end

    service_url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/#{view}"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      Alert.create(exception: "", class_name: "Faraday::ResourceNotFound",
                   message: "CouchDB report for Counter could not be retrieved.",
                   source_id: id,
                   status: 404,
                   level: Alert::FATAL)
      return ""
    end

    if view == "counter"
      CSV.generate do |csv|
        csv << ["pid_type", "pid", "html", "pdf", "total"]
        result["rows"].each { |row| csv << ["doi", row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << ["pid_type", "pid"] + dates
        result["rows"].each { |row| csv << ["doi", row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
  end

  def config_fields
    [:url]
  end

  def cron_line
    config.cron_line || "* 4 * * *"
  end
end
