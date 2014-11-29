# encoding: UTF-8

namespace :db do
  namespace :works do
    desc "Bulk-load works from Crossref API"
    task :import => :environment do
      # only run if configuration option ENV['IMPORT'],
      # or ENV['MEMBER'] and/or ENV['SAMPLE'] are provided
      exit unless ENV['IMPORT'] || ENV['MEMBER'] || ENV['SAMPLE']

      case ENV['IMPORT']
      when "MEMBER"
        member = ENV['MEMBER'] || Publisher.pluck(:crossref_id).join(",")
        sample = ENV['SAMPLE']
      when "MEMBER_SAMPLE"
        member = ENV['MEMBER'] || Publisher.pluck(:crossref_id).join(",")
        sample = ENV['SAMPLE'] || 20
      when "SAMPLE"
        member = ENV['MEMBER']
        sample = ENV['SAMPLE'] || 20
      else
        member = ENV['MEMBER']
        sample = ENV['SAMPLE']
      end

      options = { from_update_date: ENV['FROM_UPDATE_DATE'],
                  until_update_date: ENV['UNTIL_UPDATE_DATE'],
                  from_pub_date: ENV['FROM_PUB_DATE'],
                  until_pub_date: ENV['UNTIL_PUB_DATE'],
                  type: ENV['TYPE'],
                  member: member,
                  issn: ENV['ISSN'],
                  sample: sample }
      import = Import.new(options)
      number = ENV['SAMPLE'] || import.total_results
      import.queue_work_import if number.to_i > 0
      puts "Started import of #{number} works in the background..."
    end

    desc "Bulk-load works from standard input"
    task :load => :environment do
      input = []
      $stdin.each_line { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) } unless $stdin.tty?

      number = input.length
      member = ENV['MEMBER']
      if member.nil? && Publisher.pluck(:crossref_id).length == 1
        # if we have only configured a single publisher
        member = Publisher.pluck(:crossref_id).first
      end

      if number > 0
        # import in batches of 1,000 works
        input.each_slice(1000) do |batch|
          import = Import.new(file: batch, member: member)
          import.queue_work_import
        end
        puts "Started import of #{number} works in the background..."
      else
        puts "No works to import."
      end
    end

    desc "Delete works"
    task :delete => :environment do
      if ENV['MEMBER'].blank?
        puts "Please use MEMBER environment variable. No work deleted."
        exit
      end

      Work.queue_work_delete(ENV['MEMBER'])
      if ENV['MEMBER'] == "all"
        puts "Started deleting all works in the background..."
      else
        puts "Started deleting all works from MEMBER #{ENV['MEMBER']} in the background..."
      end
    end

    desc "Add missing sources"
    task :add_sources, [:date] => :environment do |_, args|
      if args.date.nil?
        puts "Date in format YYYY-MM-DD required"
        exit
      end

      works = Work.where("published_on >= ?", args.date)

      if args.extras.empty?
        sources = Source.all
      else
        sources = Source.where("name in (?)", args.extras)
      end

      traces = []
      works.each do |work|
        sources.each do |source|
          trace = Trace.where(work_id: work.id, source_id: source.id).find_or_initialize
          if trace.new_record?
            trace.save!
            traces << trace
          end
        end
      end

      puts "#{traces.count} trace(s) added for #{sources.count} source(s) and #{works.count} works"
    end

    desc "Remove all HTML and XML tags from work titles"
    task :sanitize_title => :environment do
      Work.all.each { |work| work.save }
      puts "#{Work.count} work titles sanitized"
    end

    desc "Add publication year, month and day"
    task :date_parts => :environment do
      begin
        start_date = Date.parse(ENV['START_DATE']) if ENV['START_DATE']
      rescue => e
        # raises error if invalid date supplied
        puts "Error: #{e.message}"
        exit
      end

      if start_date
        puts "Adding date parts for all works published since #{start_date}."
        works = Work.where("published_on >= ?", start_date)
      else
        works = Work.all
      end

      works.each do |work|
        work.update_date_parts
        work.save
      end
      puts "Date parts for #{works.count} works added"
    end
  end

  namespace :notifications do
    desc "Resolve all notifications with level INFO and WARN"
    task :resolve => :environment do
      Notification.unscoped do
        before = Notification.count
        Notification.where("level < 3").update_all(unresolved: false)
        after = Notification.count
        puts "Deleted #{before - after} resolved notifications, #{after} unresolved notifications remaining"
      end
    end

    desc "Delete all resolved notifications"
    task :delete => :environment do
      Notification.unscoped do
        before = Notification.count
        Notification.where(:unresolved => false).delete_all
        after = Notification.count
        puts "Deleted #{before - after} resolved notifications, #{after} unresolved notifications remaining"
      end
    end
  end

  namespace :users do

    desc "Add user"
    task :add => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(100000).first
      unless request.nil?
        ApiRequest.where("created_at <= ?", request.created_at).delete_all
      end
      after = ApiRequest.count
      puts "Deleted #{before - after} API requests, #{after} API requests remaining"
    end
  end

  namespace :api_requests do

    desc "Delete API requests, keeping last 100,000 requests"
    task :delete => :environment do
      before = ApiRequest.count
      request = ApiRequest.order("created_at DESC").offset(100000).first
      unless request.nil?
        ApiRequest.where("created_at <= ?", request.created_at).delete_all
      end
      after = ApiRequest.count
      puts "Deleted #{before - after} API requests, #{after} API requests remaining"
    end
  end

  namespace :api_responses do

    desc "Delete all API responses older than 24 hours"
    task :delete => :environment do
      before = ApiResponse.count
      ApiResponse.where("created_at < ?", Time.zone.now - 1.day).delete_all
      after = ApiResponse.count
      puts "Deleted #{before - after} API responses, #{after} API responses remaining"
    end
  end

  namespace :changes do

    desc "Delete all changes older than 24 hours"
    task :delete => :environment do
      before = Change.count
      Change.where("created_at < ?", Time.zone.now - 1.day).delete_all
      after = Change.count
      puts "Deleted #{before - after} changes, #{after} changes remaining"
    end
  end

  namespace :agents do

    desc "Activate agents"
    task :activate => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.inactive
      else
        agents = Agent.inactive.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No inactive agent found."
        exit
      end

      agents.each do |agent|
        agent.activate
        if agent.waiting?
          puts "Agent #{agent.title} has been activated and is now waiting."
        else
          puts "Agent #{agent.title} could not be activated."
        end
      end
    end

    desc "Inactivate agents"
    task :inactivate => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.active
      else
        agents = Agent.active.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No active agents found."
        exit
      end

      agents.each do |agent|
        agent.inactivate
        if agent.inactive?
          puts "Agent #{agent.title} has been inactivated."
        else
          puts "Agent #{agent.title} could not be inactivated."
        end
      end
    end

    desc "Install agents"
    task :install => :environment do |_, args|
      if args.extras.empty?
        agents = Agent.available
      else
        agents = Agent.available.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No available agent found."
        exit
      end

      agents.each do |agent|
        agent.install
        unless agent.available?
          puts "Agent #{agent.title} has been installed."
        else
          puts "Agent #{agent.title} could not be installed."
        end
      end
    end

    desc "Uninstall agents"
    task :uninstall => :environment do |_, args|
      if args.extras.empty?
        puts "No agent name provided."
        exit
      else
        agents = Agent.installed.where("name in (?)", args.extras)
      end

      if agents.empty?
        puts "No installed agent found."
        exit
      end

      agents.each do |agent|
        agent.uninstall
        if agent.available?
          puts "Agent #{agent.title} has been uninstalled."
        elsif agent.retired?
          puts "Agent #{agent.title} has been retired."
        else
          puts "Agent #{agent.title} could not be uninstalled."
        end
      end
    end
  end
end
