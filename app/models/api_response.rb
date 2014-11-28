class ApiResponse < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :agent
  belongs_to :task

  scope :total, ->(duration) { where("created_at > ?", Time.zone.now.to_date - duration.days) }
  scope :slow, ->(number) { where("duration >= ?", number * 1000).where(skipped: false) }
end
