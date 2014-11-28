# encoding: UTF-8

class RetrievalHistory < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  belongs_to :trace
  belongs_to :work
  belongs_to :source

  default_scope { order("retrieved_at DESC") }

  def self.delete_many_documents(options = {})
    number = 0

    start_date = options[:start_date] || (Date.today - 5.years).to_s
    end_date = options[:end_date] || Date.today.to_s
    collection = RetrievalHistory.select(:id).where(created_at: start_date..end_date)

    collection.find_in_batches do |rh_ids|
      ids = rh_ids.map(&:id)
      Delayed::Job.enqueue RetrievalHistoryJob.new(ids), queue: "couchdb", priority: 4
      number += ids.length
    end
    number
  end
end
