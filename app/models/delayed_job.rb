class DelayedJob < ActiveRecord::Base
  belongs_to :agent, :primary_key => "queue", :foreign_key => "name", :touch => true
end
