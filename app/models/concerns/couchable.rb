module Couchable
  extend ActiveSupport::Concern

  included do
    def get_lagotto_data(id = "", options={})
      get_result("#{ENV['COUCHDB_URL']}/#{id}", options)
    end

    def get_lagotto_rev(id, options={})
      head_lagotto_data("#{ENV['COUCHDB_URL']}/#{id}", options)[:rev]
    end

    def head_lagotto_data(url, options = { timeout: DEFAULT_TIMEOUT })
      conn = faraday_conn('json')
      conn.basic_auth(options[:username], options[:password]) if options[:username]
      conn.options[:timeout] = options[:timeout]
      response = conn.head url

      # CouchDB revision is in etag header. We need to remove extra double quotes
      { rev: response.env[:response_headers][:etag][1..-2] }
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options.merge(head: true))
    end

    def save_lagotto_data(id, options = { data: nil })
      data_rev = get_lagotto_rev(id)
      if data_rev.present?
        options[:data][:_id] = "#{id}"
        options[:data][:_rev] = data_rev
      end

      put_lagotto_data("#{ENV['COUCHDB_URL']}/#{id}", options)
    end

    def put_lagotto_data(url, options = { data: nil })
      # return nil unless options[:data] || Rails.env.test?

      conn = faraday_conn('json')
      conn.options[:timeout] = DEFAULT_TIMEOUT
      response = conn.put url do |request|
        request.body = options[:data]
      end

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def remove_lagotto_data(id)
      data_rev = get_lagotto_rev(id)
      timestamp = Time.zone.now.utc.iso8601

      if data_rev.present?
        params = {'rev' => data_rev }
        response = delete_lagotto_data("#{ENV['COUCHDB_URL']}/#{id}?#{params.to_query}")
      else
        response = nil
      end

      if response.nil?
        Rails.logger.warn "#{timestamp}: CouchDB document #{id} not found"
      elsif response.respond_to?(:error)
        Rails.logger.error "#{timestamp}: CouchDB document #{id} could not be deleted: #{response[:error]}"
      else
        Rails.logger.info "#{timestamp}: CouchDB document #{id} deleted with rev #{response}"
      end

      response
    end

    def delete_lagotto_data(url, options={})
      # don't delete database
      return nil if url == ENV['COUCHDB_URL'] && Rails.env != "test"

      conn = faraday_conn('json')
      response = conn.delete url

      parse_rev(response.body)
    rescue *NETWORKABLE_EXCEPTIONS => e
      rescue_faraday_error(url, e, options)
    end

    def get_lagotto_database
      get_lagotto_data
    end

    def put_lagotto_database
      put_lagotto_data(ENV['COUCHDB_URL'])
      # filter = Faraday::UploadIO.new("#{Rails.root}/design_doc/filter.json", "application/json")
      # put_lagotto_data("#{ENV['COUCHDB_URL']}/_design/filter", data: filter)

      # reports = Faraday::UploadIO.new("#{Rails.root}/design_doc/reports.json", "application/json")
      # put_lagotto_data("#{ENV['COUCHDB_URL']}/_design/reports", data: reports)
    end

    def delete_lagotto_database
      delete_lagotto_data(ENV['COUCHDB_URL'])
    end

    def parse_rev(string)
      if is_json?(string)
        json = JSON.parse(string)
        json['ok'] ? json['rev'] : nil
      else
        { error: 'malformed JSON response' }
      end
    end
  end
end
