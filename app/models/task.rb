class Task < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :agent
  has_many :retrieval_histories

  before_destroy :delete_couchdb_document

  serialize :event_metrics
  serialize :other, OpenStruct

  delegate :name, :to => :agent
  delegate :title, :to => :agent
  delegate :group, :to => :agent

  scope :queued, -> { where("queued_at > ?", "1970-01-01") }
  scope :not_queued, -> { where("queued_at = ?", "1970-01-01") }
  scope :stale, -> { not_queued.where("scheduled_at < ?", Time.zone.now).order("scheduled_at") }
  scope :published, -> { joins(:work).not_queued.where("works.published_on <= ?", Time.zone.now.to_date) }

  scope :by_agent, ->(agent_id) { where(:agent_id => agent_id) }
  scope :by_name, ->(agent) { joins(:agent).where("agents.name = ?", agent) }
  scope :with_agents, -> { joins(:agent).where("agents.state > ?", 0).order("group_id, title") }

  def data
    @data ||= event_count > 0 ? get_lagotto_data("#{agent.name}:#{work.uid_escaped}") : nil
  end

  def events
    @events ||= (data.blank? || data[:error]) ? [] : data["events"]
  end

  def by_day
    @by_day ||= (data.blank? || data[:error]) ? [] : data["events_by_day"]
  end

  def by_month
    @by_month ||= (data.blank? || data[:error]) ? [] : data["events_by_month"]
  end

  def by_year
    return [] if by_month.blank?

    by_month.group_by { |event| event["year"] }.sort.map do |k, v|
      if ['counter', 'pmc', 'figshare', 'copernicus'].include?(name)
        { year: k.to_i,
          pdf: v.reduce(0) { |sum, hash| sum + hash['pdf'].to_i },
          html: v.reduce(0) { |sum, hash| sum + hash['html'].to_i } }
      else
        { year: k.to_i,
          total: v.reduce(0) { |sum, hash| sum + hash['total'].to_i } }
      end
    end
  end

  def events_csl
    @events_csl ||= events.is_a?(Array) ? events.map { |event| event['event_csl'] }.compact : []
  end

  def metrics
    @metrics ||= event_metrics.present? ? event_metrics : get_event_metrics(total: 0)
  end

  def new_metrics
    @new_metrics ||= { :pdf => metrics[:pdf],
                       :html => metrics[:html],
                       :readers => metrics[:shares],
                       :comments => metrics[:comments],
                       :likes => metrics[:likes],
                       :total => metrics[:total] }
  end

  def group_name
    @group_name ||= group.name
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{update_date}"
  end

  # calculate datetime when trace should be updated, adding random interval
  # agents that are not queueable use a fixed date
  def stale_at
    unless agent.kind == "work"
      cron_parser = CronParser.new(agent.cron_line)
      return cron_parser.next(Time.zone.now)
    end

    age_in_days = Date.today - work.published_on
    if (0..7).include?(age_in_days)
      random_time(agent.staleness[0])
    elsif (8..31).include?(age_in_days)
      random_time(agent.staleness[1])
    elsif (32..365).include?(age_in_days)
      random_time(agent.staleness[2])
    else
      random_time(agent.staleness.last)
    end
  end

  def random_time(duration)
    Time.zone.now + duration + rand(duration/10)
  end

  private

  def delete_couchdb_document
    couchdb_id = "#{agent.name}:#{work.uid_escaped}"
    remove_lagotto_data(couchdb_id)
  end
end
