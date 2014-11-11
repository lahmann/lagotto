class ApiResponse < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :agent
  belongs_to :task

  attr_accessible :message

  scope :unresolved, where("unresolved = ?", true)
  scope :filter, lambda { |id| where("unresolved = ?", true).where("id <= ?", id) }
  scope :total, lambda { |duration| where("created_at > ?", Time.zone.now - duration.days) }
  scope :decreasing, lambda { |agent_ids| where("event_count < previous_count").where(skipped: false).where(agent_id: agent_ids) }
  scope :increasing, lambda { |number, agent_ids| where("update_interval IS NOT NULL").where("((event_count - previous_count) / update_interval) >= ?", number).where(agent_id: agent_ids) }
  scope :slow, lambda { |number| where("duration >= ?", number * 1000).where(skipped: false) }
  scope :article_not_updated, lambda { |number| where("event_count IS NULL").where("update_interval >= ?", number) }
  scope :source_not_updated, lambda { |number| where("update_interval >= ?", number) }

  # we need integer division, which is handled differently by MySQL and Postgres. Workaround is to use FLOOR.
  scope :citation_milestone, lambda { |number, agent_ids|
    if number == 0
      limit(0)
    else
      where("FLOOR(event_count / ?) > FLOOR(previous_count / ?)", number, number).where("source_id IN (?)", agent_ids)
    end
  }

  def get_html_ratio
    filter_path = "_design/filter/_view/html_ratio?startkey=\"#{created_at.utc.iso8601}\""
    data = get_lagotto_data(filter_path, timeout: 10 * DEFAULT_TIMEOUT)
    if data && data["rows"]
      data["rows"]
    else
      []
    end
  end
end
