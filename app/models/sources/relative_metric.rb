class RelativeMetric < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url % { :doi => work.doi_escaped }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = get_extra(result, work.published_on.year)

    total = extra[:subject_areas].reduce(0) { | sum, subject_area | sum + subject_area[:average_usage].reduce(:+) }

    { events: [],
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(total: total),
      extra: extra }
  end

  def get_extra(result, year)
    { start_date: "#{year}-01-01T00:00:00Z",
      end_date: Date.civil(year, -1, -1).strftime("%Y-%m-%dT00:00:00Z"),
      subject_areas: Array(result.fetch("rows", nil)).map do |row|
        value = row.fetch("value", {})
        { subject_area: value.fetch("subject_area", nil),
          average_usage: value.fetch("data", nil) }
      end }
  end

  def config_fields
    [:url]
  end
end
