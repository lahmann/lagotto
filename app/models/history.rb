require "cgi"

class History
  # we can get data_from_source in 3 different formats
  # - hash with event_count == 0:         SUCCESS NO DATA
  # - hash with event_count >  0:         SUCCESS
  # - hash with event_count nil or error: ERROR
  #
  # SUCCESS NO DATA
  # The source knows about the work identifier, but returns an event_count of 0
  #
  # SUCCESS
  # The source knows about the work identifier, and returns an event_count > 0
  #
  # ERROR
  # An error occured, typically 408 (Request Timeout), 403 (Too Many Requests) or 401 (Unauthorized)
  # It could also be an error in our code. 404 (Not Found) errors are handled as SUCCESS NO DATA
  # We don't update retrieval status and set skipped to true,
  # so that the request is repeated later. We could get stuck, but we see this in alerts
  #
  # This class returns a hash in the format event_count: 12, previous_count: 8, skipped: false, update_interval: 31
  # This hash can be used to track API responses, e.g. when event counts go down

  # include HTTP request helpers
  include Networkable

  # include metrics helpers
  include Measurable

  attr_accessor :retrieval_status, :works, :event_count, :previous_count, :previous_retrieved_at, :event_metrics, :events_by_day, :events_by_month, :events_url, :status, :rs_rev, :rh_rev, :data

  def initialize(rs_id, data = {})
    @retrieval_status = RetrievalStatus.find(rs_id)
    @previous_count = retrieval_status.event_count
    @previous_retrieved_at = retrieval_status.retrieved_at

    @status = case
              when data[:error] then :error
              when data[:event_count].nil? then :error
              when data[:event_count] > 0 then :success
              when data[:event_count] == 0 then :success_no_data
              end

    @event_count = data[:event_count]

    if not_error?
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      save_to_retrieval_statuses
    end

    if success?
      @works = Array(data[:events])

      @events_by_day = data[:events_by_day]
      @events_by_day = get_events_by_day if events_by_day.blank?

      @events_by_month = data[:events_by_month]
      @events_by_month = get_events_by_month if events_by_month.blank?

      save_to_works
      save_to_days
      save_to_months
    end
  end

  def save_to_retrieval_statuses
    # save data to retrieval_status table
    retrieval_status.update_attributes(retrieved_at: retrieved_at,
                                       scheduled_at: retrieval_status.stale_at,
                                       queued_at: nil,
                                       event_count: event_count,
                                       event_metrics: event_metrics,
                                       events_url: events_url)
  end

  def save_to_works
    @works.map { |item| Work.find_or_create(item) }
  end

  def save_to_days
    @events_by_day.map { |item| Day.where(retrieval_status_id: retrieval_status.id,
                                          day: item["day"],
                                          month: item["month"],
                                          year: item["year"]).first_or_create(
                                          work_id: retrieval_status.work_id,
                                          source_id: retrieval_status.source_id,
                                          total_count: item["total_count"],
                                          html_count: item["html_count"],
                                          pdf_count: item["pdf_count"]) }
  end

  def save_to_months
    @events_by_month.map { |item| Month.where(retrieval_status_id: retrieval_status.id,
                                              month: item["month"],
                                              year: item["year"]).first_or_create(
                                              work_id: retrieval_status.work_id,
                                              source_id: retrieval_status.source_id,
                                              total_count: item["total_count"],
                                              html_count: item["html_count"],
                                              pdf_count: item["pdf_count"]) }
  end

  def get_events_by_day(event_arr = nil)
    event_arr = Array(event_arr)

    # track daily events only the first 30 days after publication
    # return entry for older works
    return event_arr if today - retrieval_status.work.published_on > 30

    # count entries not including the current day
    event_arr.delete_if { |item| item['day'] == today.day && item['month'] == today.month && item['year'] == today.year }

    if ['counter', 'pmc', 'copernicus', 'figshare'].include?(retrieval_status.source.name)
      html = event_metrics[:html] - event_arr.reduce(0) { |sum, item| sum + item['html'] }
      pdf = event_metrics[:pdf] - event_arr.reduce(0) { |sum, item| sum + item['pdf'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'html_count' => html,
               'pdf_count' => pdf }
    else
      total = event_count - event_arr.reduce(0) { |sum, item| sum + item['total'] }
      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'total_count' => total }
    end

    event_arr << item
  end

  def get_events_by_month(event_arr = nil)
    event_arr = Array(event_arr)

    # count entries not including the current month
    event_arr.delete_if { |item| item['month'] == today.month && item['year'] == today.year }

    if ['copernicus', 'figshare'].include?(retrieval_status.source.name)
      html = event_metrics[:html] - event_arr.reduce(0) { |sum, item| sum + item['html'] }
      pdf = event_metrics[:pdf] - event_arr.reduce(0) { |sum, item| sum + item['pdf'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'html_count' => html,
               'pdf_count' => pdf }
    else
      total = event_count - event_arr.reduce(0) { |sum, item| sum + item['total'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'total_count' => total }
    end

    event_arr << item
  end

  def not_error?
    status != :error
  end

  def success?
    status == :success
  end

  def skipped
    not_error? ? false : true
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def update_interval
    if [Date.new(1970, 1, 1), today].include?(previous_retrieved_at.to_date)
      1
    else
      (today - previous_retrieved_at.to_date).to_i
    end
  end

  def retrieved_at
    Time.zone.now
  end

  def data
    { pid: retrieval_status.work.pid,
      retrieved_at: retrieved_at,
      source: retrieval_status.source.name,
      events: events,
      events_url: events_url,
      event_metrics: event_metrics,
      events_by_day: events_by_day,
      events_by_month: events_by_month,
      doc_type: "current" }
  end

  def to_hash
    { event_count: event_count,
      previous_count: previous_count,
      skipped: skipped,
      update_interval: update_interval }
  end
end
