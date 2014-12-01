class History
  # we can get data_from_source in 3 different formats
  # - hash with event_count = 0: SUCCESS NO DATA
  # - hash with event_count > 0: SUCCESS
  # - hash with error          : ERROR
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

  # include CouchDB helpers
  include Couchable

  # include metrics helpers
  include Measurable

  attr_accessor :trace, :events, :event_count, :previous_count, :previous_retrieved_at, :event_metrics, :events_by_day, :events_by_month, :events_url, :status, :couchdb_id, :trace_rev, :rh_rev, :data

  def initialize(data = {})
    work = Work.where(doi: data[:doi]).first
    source = Source.where(name: data[:source]).first
    if work && source
      @trace = Trace.where(work_id: work.id, source_id: source.id).first_or_create

      @previous_count = trace.event_count
      @previous_retrieved_at = trace.retrieved_at

      # Track changes to traces
      response = { work_id: trace.work_id,
                   source_id: trace.source_id,
                   trace_id: trace.id,
                   event_count: event_count,
                   previous_count: previous_count,
                   update_interval: update_interval,
                   skipped: skipped }
      ActiveSupport::Notifications.instrument("change.get") do |payload|
        payload.merge!(response)
      end
    end

    @status = case
              when data[:error] then :error
              when data[:event_count] > 0 then :success
              when data[:event_count] == 0 then :success_no_data
              end

    @event_count = data[:event_count]

    if not_error?
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      save_to_mysql
    end

    if success?
      @events = data[:events]
      @events_by_day = data[:events_by_day]
      @events_by_month = data[:events_by_month]

      save_to_couchdb
    end
  end

  def save_to_mysql
    # save data to traces table
    trace.update_attributes(retrieved_at: retrieved_at,
                            event_count: event_count,
                            event_metrics: event_metrics,
                            events_url: events_url)
  end

  def save_to_couchdb
    if events_by_day.blank? || events_by_month.blank?
      # check for existing couchdb document
      data_rev = get_lagotto_rev(couchdb_id)

      if data_rev.present?
        previous_data = get_lagotto_data(couchdb_id)
        previous_data = {} if previous_data.nil? || previous_data[:error]
      else
        previous_data = {}
      end

      @events_by_day = get_events_by_day(previous_data['events_by_day']) if events_by_day.blank?
      @events_by_month = get_events_by_month(previous_data['events_by_month']) if events_by_month.blank?

      options = { data: data.clone }
      options[:source_id] = trace.source_id

      if data_rev.present?
        options[:data][:_id] = "#{couchdb_id}"
        options[:data][:_rev] = data_rev
      end

      @trace_rev = put_lagotto_data("#{ENV['COUCHDB_URL']}/#{couchdb_id}", options)
    else
      # only save the data to couchdb
      @trace_rev = save_lagotto_data(couchdb_id, data: data.clone, source_id: trace.source_id)
    end
  end

  def get_events_by_day(event_arr = nil)
    event_arr = Array(event_arr)

    # track daily events only the first 30 days after publication
    # return entry for older works
    return event_arr if today - trace.work.published_on > 30

    # count entries not including the current day
    event_arr.delete_if { |item| item['day'] == today.day && item['month'] == today.month && item['year'] == today.year }

    if ['counter', 'pmc', 'copernicus', 'figshare'].include?(trace.source.name)
      html = event_metrics[:html] - event_arr.reduce(0) { |sum, item| sum + item['html'] }
      pdf = event_metrics[:pdf] - event_arr.reduce(0) { |sum, item| sum + item['pdf'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'html' => html,
               'pdf' => pdf }
    else
      total = event_count - event_arr.reduce(0) { |sum, item| sum + item['total'] }
      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'total' => total }
    end

    event_arr << item
  end

  def get_events_by_month(event_arr = nil)
    event_arr = Array(event_arr)

    # count entries not including the current month
    event_arr.delete_if { |item| item['month'] == today.month && item['year'] == today.year }

    if ['copernicus', 'figshare'].include?(trace.source.name)
      html = event_metrics[:html] - event_arr.reduce(0) { |sum, item| sum + item['html'] }
      pdf = event_metrics[:pdf] - event_arr.reduce(0) { |sum, item| sum + item['pdf'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'html' => html,
               'pdf' => pdf }
    else
      total = event_count - event_arr.reduce(0) { |sum, item| sum + item['total'] }

      item = { 'year' => today.year,
               'month' => today.month,
               'total' => total }
    end

    event_arr << item
  end

  def not_error?
    status != :error
  end

  def success?
    status == :success
  end

  def couchdb_id
    "#{trace.source.name}:#{trace.work.uid_escaped}"
  end

  def skipped
    not_error? ? false : true
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def update_interval
    if previous_retrieved_at.nil?
      nil
    elsif [Date.new(1970, 1, 1), today].include?(previous_retrieved_at.to_date)
      1
    else
      (today - previous_retrieved_at.to_date).to_i
    end
  end

  def retrieved_at
    Time.zone.now
  end

  def data
    { ENV['UID'].to_sym => trace.work.uid,
      retrieved_at: retrieved_at,
      source: trace.source.name,
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
