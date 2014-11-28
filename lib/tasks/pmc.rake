require 'date'
require 'addressable/uri'

namespace :pmc do
  desc "Bulk-import PMC usage stats by month and journal"
  task :update => :environment do
    # silently exit if pmc agent is not available
    agent = Agent.active.where(name: "pmc").first
    exit if agent.nil?

    dates = Report.date_range(source: "pmc", month: ENV['MONTH'], year: ENV['YEAR'])

    dates.each do |date|
      journals_with_errors = agent.get_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been saved"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be saved for #{journals_with_errors.join(', ')}"
        exit
      end
      journals_with_errors = agent.parse_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been parsed"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be parsed for #{journals_with_errors.join(', ')}"
      end
    end
  end
end
