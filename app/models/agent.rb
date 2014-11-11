require 'cgi'
require "addressable/uri"

class Agent < ActiveRecord::Base
  # include state machine
  include Statable

  # include default methods for subclasses
  include Configurable

  # include methods for calculating metrics
  include Measurable

  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include date methods concern
  include Dateable

  # include summary counts
  include Countable

  # include hash helper
  include Hashie::Extensions::DeepFetch

  has_many :tasks, :dependent => :destroy
  has_many :articles, :through => :tasks
  has_many :publishers, :through => :tasks
  has_many :alerts
  has_many :api_responses
  has_many :delayed_jobs, primary_key: "name", foreign_key: "queue", :dependent => :destroy
  belongs_to :group

  serialize :config, OpenStruct

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validates :priority, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :workers, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :timeout, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :wait_time, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_queries, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :max_failed_query_time_interval, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :job_batch_size, :numericality => { :only_integer => true }, :inclusion => { :in => 1..1000, :message => "should be between 1 and 1000" }
  validates :rate_limiting, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_week, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_month, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_year, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :staleness_all, :numericality => { :only_integer => true, :greater_than => 0 }
  validate :validate_cron_line_format, :allow_blank => true

  scope :available, where("state = ?", 0).order("group_id, agents.display_name")
  scope :installed, where("state > ?", 0).order("group_id, agents.display_name")
  scope :retired, where("state = ?", 1).order("group_id, agents.display_name")
  scope :visible, where("state > ?", 1).order("group_id, agents.display_name")
  scope :inactive, where("state = ?", 2).order("group_id, agents.display_name")
  scope :active, where("state > ?", 2).order("group_id, agents.display_name")
  scope :for_events, where("state > ?", 2).where("name != ?", 'relativemetric').order("group_id, agents.display_name")
  scope :queueable, where("state > ?", 2).where("queueable = ?", true).order("group_id, agents.display_name")

  def to_param  # overridden, use name instead of id
    name
  end

  def remove_queues
    delayed_jobs.delete_all
    retrieval_statuses.update_all(["queued_at = ?", nil])
  end

  def queue_all_articles(options = {})
    return 0 unless active?

    # find articles that need to be updated. Not queued currently, scheduled_at doesn't matter
    rs = retrieval_statuses

    # optionally limit to articles scheduled_at in the past
    rs = rs.stale unless options[:all]

    # optionally limit by publication date
    if options[:start_date] && options[:end_date]
      rs = rs.joins(:article).where("articles.published_on" => options[:start_date]..options[:end_date])
    end

    rs = rs.order("retrieval_statuses.id").pluck("retrieval_statuses.id")
    count = queue_article_jobs(rs, priority: priority)
  end

  def queue_article_jobs(rs, options = {})
    return 0 unless active?

    if rs.length == 0
      wait
      return 0
    end

    rs.each_slice(job_batch_size) do |rs_ids|
      Delayed::Job.enqueue SourceJob.new(rs_ids, id), queue: name, run_at: schedule_at, priority: priority
    end

    rs.length
  end

  def schedule_at
    last_job = DelayedJob.where(queue: name).maximum(:run_at)
    return Time.zone.now if last_job.nil?

    last_job + batch_interval
  end

  # condition for not adding more jobs and disabling the source
  def check_for_failures
    failed_queries = Alert.where("source_id = ? AND level > 1 AND updated_at > ?", id, Time.zone.now - max_failed_query_time_interval).count
    failed_queries > max_failed_queries
  end

  # limit the number of workers per source
  def check_for_available_workers
    workers >= working_count
  end

  def check_for_active_workers
    working_count > 1
  end

  def get_data(article, options={})
    query_url = get_query_url(article)
    if query_url.nil?
      result = {}
    else
      result = get_result(query_url, options.merge(request_options))

      # make sure we return a hash
      result = { 'data' => result } unless result.is_a?(Hash)
    end

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, article, options = {})
    # turn result into a hash for easier parsing later
    result = { 'data' => result } unless result.is_a?(Hash)

    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    # return early if an error occured that is not a not_found error
    return result if result[:error]

    options.merge!(response_options)
    metrics = options[:metrics] || :citations

    events = get_events(result)

    { events: events,
      events_by_day: get_events_by_day(events, article),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(article),
      event_count: events.length,
      event_metrics: get_event_metrics(metrics => events.length) }
  end

  def get_events_by_day(events, article)
    events = events.reject { |event| event[:event_time].nil? || Date.iso8601(event[:event_time]) - article.published_on > 30 }

    events.group_by { |event| event[:event_time][0..9] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        day: k[8..9].to_i,
        total: v.length }
    end
  end

  def get_events_by_month(events)
    events = events.reject { |event| event[:event_time].nil? }

    events.group_by { |event| event[:event_time][0..6] }.sort.map do |k, v|
      { year: k[0..3].to_i,
        month: k[5..6].to_i,
        total: v.length }
    end
  end

  def request_options
    {}
  end

  def response_options
    {}
  end

  def get_query_url(article)
    if url.present? && article.doi.present?
      url % { :doi => article.doi_escaped }
    end
  end

  def get_events_url(article)
    if events_url.present? && article.doi.present?
      events_url % { :doi => article.doi_escaped }
    end
  end

  def get_author(author)
    return '' if author.blank?

    name_parts = author.split(' ')
    family = name_parts.last
    given = name_parts.length > 1 ? name_parts[0..-2].join(' ') : ''

    [{ 'family' => String(family).titleize,
       'given' => String(given).titleize }]
  end

  # fields with publisher-specific settings such as API keys,
  # i.e. everything that is not a URL
  def publisher_fields
    config_fields.select { |field| field !~ /url/ }
  end

  # all publisher-specific configurations
  def publisher_configs
    return [] unless by_publisher?

    tasks.pluck_all(:publisher_id, :config)
  end

  def publisher_config(publisher_id)
    conf = publisher_configs.find { |conf| conf["publisher_id"] == publisher_id }
    conf.nil? ? OpenStruct.new : conf["config"]
  end

  # all other fields
  def url_fields
    config_fields.select { |field| field =~ /url/ }
  end

  # Custom validations that are triggered in state machine
  def validate_config_fields
    config_fields.each do |field|

      # Some fields can be blank
      next if name == "crossref" && [:username, :password].include?(field)
      next if name == "pmc" && [:journals, :username, :password].include?(field)
      next if name == "mendeley" && field == :access_token
      next if name == "twitter_search" && field == :access_token
      next if name == "scopus" && field == :insttoken

      errors.add(field, "can't be blank") if send(field).blank?
    end
  end

  # Custom validation for cron_line field
  def validate_cron_line_format
    cron_parser = CronParser.new(cron_line)
    cron_parser.next(Time.zone.now)
  rescue ArgumentError
    errors.add(:cron_line, "is not a valid crontab entry")
  end

  def cache_key
    "#{name}/#{update_date}"
  end

  def update_date
    cached_at.utc.iso8601
  end

  def update_cache
    DelayedJob.delete_all(queue: "#{name}-cache")
    delay(priority: 1, queue: "#{name}-cache").write_cache
  end

  def write_cache
    # update cache_key as last step so that we have the old version until we are done
    now = Time.zone.now
    timestamp = now.utc.iso8601

    # loop through cached attributes we want to update
    [:queued_count,
     :stale_count,
     :response_count,
     :average_count,
     :maximum_count].each { |cached_attr| send("#{cached_attr}=", timestamp) }

    update_column(:cached_at, now)
  end

  # Remove all tasks for this agent that have never been updated,
  # return true if all records are removed
  def remove_all_tasks
    t = tasks.where(:retrieved_at == '1970-01-01').delete_all
    tasks.count == 0
  end

  # Create an empty task for every article for the new agent
  def create_tasks
    article_ids = Task.where(:agent_id => id).pluck(:article_id)

    (0...article_ids.length).step(1000) do |offset|
      ids = article_ids[offset...(offset + 1000)]
      delay(priority: 2, queue: "task").insert_tasks(ids)
    end
  end

  def insert_tasks(ids)
    sql = "insert into tasks (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), now() from articles"
    sql += " where articles.id not in (#{article_ids.join(",")})" if ids.any?

    ActiveRecord::Base.connection.execute sql
  end
end
