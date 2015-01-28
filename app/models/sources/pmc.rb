class Pmc < Source
  def parse_data(result, work, options={})
    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    return result if result[:error]

    extra = Array(result.fetch("views", nil))

    pdf = get_sum(extra, 'pdf')
    html = get_sum(extra, 'full-text')
    total = pdf + html
    events_url = total > 0 ? get_events_url(work) : nil

    { events: [],
      events_by_day: [],
      events_by_month: get_events_by_month(extra),
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total),
      extra: extra }
  end

  def get_events_by_month(extra)
    extra.map do |item|
      { month: item['month'].to_i,
        year: item['year'].to_i,
        html: item['full-text'].to_i,
        pdf: item['pdf'].to_i }
    end
  end

  # Retrieve usage stats in XML and store in /data directory. Returns an empty array if no error occured
  def get_feed(month, year, options={})
    journals_with_errors = []
    options[:source_id] = id

    publisher_configs.each do |publisher|
      publisher_id = publisher[0]
      journals_array = publisher[1].journals.to_s.split(" ")

      journals_array.each do |journal|
        feed_url = get_feed_url(publisher_id, month, year, journal)
        filename = "pmcstat_#{journal}_#{month}_#{year}.xml"

        next if save_to_file(feed_url, filename, options)

        Alert.create(:exception => "",
                     :class_name => "Net::HTTPInternalServerError",
                     :message => "PMC Usage stats for journal #{journal}, month #{month}, year #{year} could not be saved",
                     :status => 500,
                     :source_id => id)
        journals_with_errors << journal
      end
    end
    journals_with_errors
  end

  # Parse usage stats and store in CouchDB. Returns an empty array if no error occured
  def parse_feed(month, year, _options = {})
    journals_with_errors = []

    publisher_configs.each do |publisher|
      pc = publisher[1]
      next if pc.username.nil? || pc.password.nil?

      journals_array = pc.journals.to_s.split(" ")

      journals_array.each do |journal|
        filename = "pmcstat_#{journal}_#{month}_#{year}.xml"
        file = File.open("#{Rails.root}/data/#{filename}", 'r') { |f| f.read }
        document = Nokogiri::XML(file)

        status = document.at_xpath("//pmc-web-stat/response/@status").value
        if status != "0"
          error_message = document.at_xpath("//pmc-web-stat/response/error").content
          Alert.create(:exception => "", :class_name => "Net::HTTPInternalServerError",
                       :message => "PMC Usage stats for journal #{journal}, month #{month} and year #{year}: #{error_message}",
                       :status => 500,
                       :source_id => id)
          journals_with_errors << journal
        else
          # go through all the works in the xml document
          document.xpath("//work").each do |work|
            work = work.to_hash
            work = work["work"]

            doi = work["meta-data"]["doi"]
            # sometimes doi metadata are missing
            break unless doi

            view = work["usage"]
            view['year'] = year.to_s
            view['month'] = month.to_s

            # try to get the existing information about the given work
            data = get_result(db_url + CGI.escape(doi))

            if data['views'].nil?
              data = { 'views' => [view] }
            else
              # update existing entry
              data['views'].delete_if { |view| view['month'] == month.to_s && view['year'] == year.to_s }
              data['views'] << view
            end

            put_lagotto_data(db_url + CGI.escape(doi), data: data)
          end
        end
      end
    end
    journals_with_errors
  end

  def put_database
    put_lagotto_data(db_url)
  end

  def get_feed_url(publisher_id, month, year, journal)
    # check that we have publisher-specific configuration
    pc = publisher_config(publisher_id)
    return nil if pc.username.nil? || pc.password.nil?

    feed_url % { year: year, month: month, journal: journal, username: pc.username, password: pc.password }
  end

  def get_events_url(work)
    events_url % { :pmcid => work.pmcid } if work.pmcid.present?
  end

  # Format Pmc events for all works as csv
  # Show historical data if options[:format] is used
  # options[:format] can be "html", "pdf" or "combined"
  # options[:month] and options[:year] are the starting month and year, default to last month
  def to_csv(options = {})
    if ["html", "pdf", "combined"].include? options[:format]
      view = "pmc_#{options[:format]}_views"
    else
      view = "pmc"
    end

    service_url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/#{view}"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      Alert.create(exception: "", class_name: "Faraday::ResourceNotFound",
                   message: "CouchDB report for PMC could not be retrieved.",
                   source_id: id,
                   status: 404,
                   level: Alert::FATAL)
      return nil
    end

    if view == "pmc"
      CSV.generate do |csv|
        csv << ["pid_type", "pid", "html", "pdf", "total"]
        result["rows"].each { |row| csv << ["doi", row["key"], row["value"]["html"], row["value"]["pdf"], row["value"]["total"]] }
      end
    else
      dates = date_range(options).map { |date| "#{date[:year]}-#{date[:month]}" }

      CSV.generate do |csv|
        csv << ["pid_type", "pid"] + dates
        result["rows"].each { |row| csv << ["doi", row["key"]] + dates.map { |date| row["value"][date] || 0 } }
      end
    end
  end

  def url
    db_url + "%{doi}"
  end

  def config_fields
    [:db_url, :feed_url, :events_url, :journals, :username, :password]
  end

  def feed_url
    config.feed_url || "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=%{year}&month=%{month}&jrid=%{journal}&user=%{username}&password=%{password}"
  end

  def events_url
    config.events_url  || "http://www.ncbi.nlm.nih.gov/pmc/works/PMC%{pmcid}"
  end

  def cron_line
    config.cron_line || "0 5 9 * *"
  end

  def by_publisher?
    true
  end
end
