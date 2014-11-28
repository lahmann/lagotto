require 'securerandom'

class Deposit < ActiveRecord::Base
  state_machine :initial => :waiting do
    state :waiting, value: 0
    state :working, value: 1
    state :failed, value: 2
    state :done, value: 3

    after_transition any - [:working] => :working do |agent|

    end

    after_transition :to => :failed do |deposit|
      Notification.create(:exception => "", :class_name => "StandardError",
                          :message => "Failed to process deposit #{deposit.uuid}.",
                          :source_id => deposit.source_id,
                          :level => Notification::FATAL)
    end

    event :start do
      transition [:waiting] => :working
      transition any => same
    end

    event :finish do
      transition [:working] => :done
      transition any => same
    end

    event :error do
      transition any => :failed
    end
  end

  serialize :data, JSON

  belongs_to :user
  belongs_to :source

  before_create :ensure_uuid

  validates :source_id, presence: true
  validates :data, presence: true

  def to_param  # overridden, use name instead of id
    uuid
  end

  def update_date
    updated_at.utc.iso8601
  end

  protected

  def ensure_uuid
    self.uuid = SecureRandom.uuid
  end
end
