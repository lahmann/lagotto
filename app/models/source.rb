# encoding: UTF-8

require 'cgi'
require "addressable/uri"

class Source < ActiveRecord::Base
  # include summary counts
  include Countable

  has_many :retrieval_statuses, :dependent => :destroy
  has_many :articles, :through => :retrieval_statuses
  has_many :alerts
  has_many :api_responses
  belongs_to :group

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true

  scope :active, where("active = ?", 1).order("group_id, sources.display_name")

  # some sources cannot be redistributed
  scope :public_sources, lambda { where("private = ?", false) }
  scope :private_sources, lambda { where("private = ?", true) }

  def to_param  # overridden, use name instead of id
    name
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
    [:event_count,
     :article_count].each { |cached_attr| send("#{cached_attr}=", timestamp) }

    update_column(:cached_at, now)
  end

  # Remove all retrieval records for this source that have never been updated,
  # return true if all records are removed
  def remove_all_retrievals
    rs = retrieval_statuses.where(:retrieved_at == '1970-01-01').delete_all
    retrieval_statuses.count == 0
  end

  # Create an empty retrieval record for every article for the new source
  def create_retrievals
    article_ids = RetrievalStatus.where(:source_id => id).pluck(:article_id)

    (0...article_ids.length).step(1000) do |offset|
      ids = article_ids[offset...(offset + 1000)]
      delay(priority: 2, queue: "retrieval-status").insert_retrievals(ids)
    end
  end

  def insert_retrievals(ids)
    sql = "insert into retrieval_statuses (article_id, source_id, created_at, updated_at, scheduled_at) select id, #{id}, now(), now(), now() from articles"
    sql += " where articles.id not in (#{article_ids.join(",")})" if ids.any?

    ActiveRecord::Base.connection.execute sql
  end
end
