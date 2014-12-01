class Event < ActiveRecord::Base
  # include date helpers
  include Dateable

  # include custom validations
  include Validateable

  belongs_to :work, :touch => true
  belongs_to :source

  serialize :author, JSON

  validates :source_id, :title, :url, presence: true
  validates :year, numericality: { only_integer: true }
  validate :validate_published_on

  before_validation :sanitize_title

  def issued
    { "date-parts" => [[year, month, day].reject(&:nil?)] }
  end

  def update_date
    updated_at.utc.iso8601
  end
end
