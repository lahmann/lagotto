# encoding: UTF-8

require 'csv'
require 'zip'

class Report < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_and_belongs_to_many :users

  serialize :config, OpenStruct

  def self.available(role)
    if role == "user"
      where(:private => false)
    else
      all
    end
  end

  # Array of hashes in format [{ month: 12, year: 2013 },{ month: 1, year: 2014 }]
  # Provide starting month and year as input, otherwise defaults to this month
  # PMC is only providing stats until the previous month
  def self.date_range(options = {})
    end_date = Date.today
    end_date -= 1.month if options[:source] == 'pmc'

    return [{ month: end_date.month, year: end_date.year }] unless options[:month] && options[:year]

    start_date = Date.new(options[:year].to_i, options[:month].to_i, 1)
    start_date = end_date if start_date > end_date
    (start_date..end_date).map { |date| { month: date.month, year: date.year } }.uniq
  rescue ArgumentError
    [{ month: end_date.month, year: end_date.year }]
  end

  # Generate CSV with event counts for all works and active sources
  def self.to_csv(options = {})
    if options[:include_private_sources]
      sources = Source.active
    else
      sources = Source.active.where(:private => false)
    end

    sql = "SELECT a.#{ENV['UID']}, a.published_on, a.title"
    sources.each do |source|
      sql += ", MAX(CASE WHEN rs.source_id = #{source.id} THEN rs.event_count END) AS #{source.name}"
    end
    sql += " FROM works a LEFT JOIN traces rs ON a.id = rs.work_id GROUP BY a.id"
    sanitized_sql = sanitize_sql_for_conditions(sql)
    results = ActiveRecord::Base.connection.exec_query(sanitized_sql)

    CSV.generate do |csv|
      csv << [ENV['UID'], "publication_date", "title"] + sources.map(&:name)
      results.each { |row| csv << row.values }
    end
  end

  # Format usage stats stored in CouchDB for all works as csv
  # options[:source] can be "counter" or "pmc"
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def self.usage_csv(options = {})
    source = options[:source]
    return nil unless ["counter", "pmc"].include?(source)

    if ["html", "pdf", "xml", "combined"].include? options[:format]
      view = "#{source}_#{options[:format]}_views"
    else
      view = source
    end

    service_url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/#{view}"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      Notification.create(exception: "", class_name: "Faraday::ResourceNotFound",
                          message: "CouchDB report for #{source} could not be retrieved.",
                          status: 404,
                          level: Notification::FATAL)
      return nil
    end

    if view == source
      CSV.generate do |csv|
        csv << [ENV['UID'], "html", "pdf", "total"]
        result["rows"].each { |row| csv << [row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << [ENV['UID']] + dates
        result["rows"].each { |row| csv << [row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
  end

  # write report into folder with current date in name
  def self.write(filename, content, options = {})
    return nil unless filename && content

    date = options[:date] || Date.today.iso8601
    folderpath = "#{Rails.root}/data/report_#{date}"
    Dir.mkdir folderpath unless Dir.exist? folderpath
    filepath = "#{folderpath}/#{filename}"
    if IO.write(filepath, content)
      filepath
    else
      nil
    end
  end

  def self.read_stats(stat, options = {})
    date = options[:date] || Date.today.iso8601
    filename = "#{stat[:name]}.csv"
    filepath = "#{Rails.root}/data/report_#{date}/#{filename}"
    if File.exist?(filepath)
      CSV.read(filepath, headers: stat[:headers] ? stat[:headers] : :first_row, return_headers: true)
    else
      nil
    end
  end

  def self.merge_stats(options = {})
    if options[:include_private_sources]
      alm_stats = read_stats(name: "alm_private_stats")
    else
      alm_stats = read_stats(name: "alm_stats")
    end
    return nil if alm_stats.blank?

    stats = [{ name: "mendeley_stats", headers: [ENV['UID'], "mendeley_readers", "mendeley_groups", "mendeley"] },
             { name: "pmc_stats", headers: [ENV['UID'], "pmc_html", "pmc_pdf", "pmc"] },
             { name: "counter_stats", headers: [ENV['UID'], "counter_html", "counter_pdf", "counter"] }]
    stats.each do |stat|
      stat[:csv] = read_stats(stat, options).to_a
    end

    # return alm_stats if no additional stats are found
    stats.reject! { |stat| stat[:csv].blank? }
    return alm_stats if stats.empty?

    CSV.generate do |csv|
      alm_stats.each do |row|
        stats.each do |stat|
          # find row based on uid, and discard the first and last item (uid and total). Otherwise pad with zeros
          match = stat[:csv].assoc(row.field(ENV['UID']))
          match = match.present? ? match[1..-2] : [0, 0]
          row.push(*match)
        end
        csv << row
      end
    end
  end

  def self.zip_file(options = {})
    date = options[:date] || Date.today.iso8601
    filename = "alm_report_#{date}.csv"
    filepath = "#{Rails.root}/data/report_#{date}/alm_report.csv"
    zip_filepath = "#{Rails.root}/public/files/alm_report.zip"
    return nil unless File.exist? filepath

    Zip::File.open(zip_filepath, Zip::File::CREATE) do |zipfile|
      zipfile.add(filename, filepath)
    end
    File.chmod(0755, zip_filepath)
    zip_filepath
  end

  def self.zip_folder(options = {})
    date = options[:date] || Date.today.iso8601
    folderpath = "#{Rails.root}/data/report_#{date}"
    zip_filepath = "#{Rails.root}/data/report_#{date}.zip"
    return nil unless File.exist? folderpath

    Zip::File.open(zip_filepath, Zip::File::CREATE) do |zipfile|
      Dir["#{folderpath}/*"].each do |filepath|
        zipfile.add(File.basename(filepath), filepath)
      end
    end
    FileUtils.rm_rf(folderpath)
    zip_filepath
  end

  def interval
    config.interval || 1.day
  end

  def interval=(value)
    config.interval = value
  end

  # Reports are sent via delayed_job

  def send_error_report
    ReportMailer.delay(queue: 'mailer', priority: 6).send_error_report(self)
  end

  def send_status_report
    ReportMailer.delay(queue: 'mailer', priority: 6).send_status_report(self)
  end

  def send_work_statistics_report
    ReportMailer.delay(queue: 'mailer', priority: 6).send_work_statistics_report(self)
  end

  def send_fatal_error_report(message)
    ReportMailer.delay(queue: 'mailer', priority: 1).send_fatal_error_report(self, message)
  end

  def send_stale_source_report(source_ids)
    ReportMailer.delay(queue: 'mailer', priority: 6).send_stale_source_report(self, source_ids)
  end

  def send_missing_workers_report
    ReportMailer.send_missing_workers_report(self)
  end
end
