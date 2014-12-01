class Event < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source

end
